require 'set'

Vertex = Struct.new(:graph, :labels) do
  def initialize(graph, *labels)
    super(graph, labels.flatten)
  end

  def merge(vertex)
    unless vertex.graph.equal?(graph)
      raise ArgumentError, "Cannot merge vertices from different graphs"
    end
    self.class.new(graph, (labels + vertex.labels).sort)
  end

  def to_s
    "#<V #{labels.join(", ")}>"
  end
  alias inspect to_s
end

Edge = Struct.new(:graph, :vertex_label_1, :vertex_label_2) do
  def initialize(graph, *vls)
    super(graph, *vls.sort)
  end

  def vertex_labels
    [vertex_label_1, vertex_label_2]
  end

  def to_s
    "#<E #{vertex_label_1} #{vertex_label_2}>"
  end
  alias inspect to_s
end

class Graph
  def initialize
    if block_given?
      yield self
      graph_building_done!
    end
  end

  def self.from_file(file)
    contents = File.read(file)
    Graph.from_file_contents(contents)
  end

  def self.from_file_contents(contents)
    Graph.new do |g|
      contents.split("\n").each do |vertex_string|
        vertex_string.strip!
        label, *connected_to = vertex_string.split(/\s+/)
        g.vertex label, connected_to: connected_to
      end
    end
  end

  def deep_dup
    Marshal.load(Marshal.dump(self))
  end

  def vertices
    @vertices ||= Set.new # prevent dups
  end

  def edges
    @edges ||= [] # we can have parallel edges, so we can't use a set
  end

  def edge_for(vl1, vl2)
    edges.find { |e| e.vertex_label_1 == vl1 && e.vertex_label_2 == vl2 }
  end

  def vertex(label, options = {})
    v = vertices_hash[label]
    vertices << v

    Array(options[:connected_to]).each do |connected_label|
      edge = Edge.new(self, label, connected_label)
      next if added_edges.include?(edge)
      add_edge edge
    end
  end

  def contract_edge(edge)
    edges.delete_if { |e| e.equal?(edge) }

    v1 = vertex_for(edge.vertex_label_1)
    v2 = vertex_for(edge.vertex_label_2)
    merged = v1.merge(v2)

    vertices.subtract([v1, v2])
    vertices << merged

    delete_self_loops_for(merged)
    self
  end

private

  def vertex_for(label)
    vertices.find { |v| v.labels.include?(label) }
  end

  def delete_self_loops_for(vertex)
    edges.delete_if do |edge|
      vertex.labels.include?(edge.vertex_label_1) &&
      vertex.labels.include?(edge.vertex_label_2)
    end
  end

  def add_edge(e)
    edges << e
    added_edges << e
  end

  def vertices_hash
    @vertices_hash ||= Hash.new do |hash, label|
      hash[label] = Vertex.new(self, label)
    end
  end

  # for de-dupping
  def added_edges
    @added_edges ||= Set.new
  end

  def graph_building_done!
    extend ConstructedGraph
    @vertices_hash = nil # otherwise we can't deep-dup it
  end

  module ConstructedGraph
    def vertex(*args)
      raise "You cannot add a vertex to a completed graph"
    end
  end
end

