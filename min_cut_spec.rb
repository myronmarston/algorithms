require 'set'

class Graph
  attr_reader :edges

  def initialize
    @vertices = {}
    @edges = Set.new
  end

  def vertex_for(label, *adjacent_labels)
    @vertices.fetch(label) do
      @vertices[label] = Vertex.new(label)
    end.tap do |vertex|
      adjacent_labels.each do |adj_label|
        adj_vertex = vertex_for(adj_label)
        edges << Edge.for(vertex, adj_vertex)
        vertex.adjacent_vertices << adj_vertex
      end
    end
  end

  def deep_dup
    Marshal.load(Marshal.dump(self))
  end
end

Edge = Struct.new(:vertex_1, :vertex_2) do
  def self.for(vertex_1, vertex_2)
    new(*[vertex_1, vertex_2].sort_by(&:label))
  end

  def vertices
    [vertex_1, vertex_2]
  end

  def vertex_labels
    vertices.map(&:label)
  end
end

Vertex = Struct.new(:label) do
  def adjacent_vertices
    @adjacent_vertices ||= Set.new
  end
end

describe Edge, '.for' do
  it 'returns a new edge with the vertices consistently ordered' do
    v1 = Vertex.new("a")
    v2 = Vertex.new("b")

    e1 = Edge.for(v1, v2)
    e2 = Edge.for(v2, v1)

    e1.vertex_1.should equal(e2.vertex_1)
    e1.vertex_2.should equal(e2.vertex_2)
  end
end

describe Graph do
  let(:graph) { Graph.new }

  def v(label, *adjacent_labels)
    graph.vertex_for(label, *adjacent_labels)
  end

  it 'stores a single copy of each vertex' do
    v("a").should equal(v "a")
    v("a").should_not equal(v "b")
  end

  it 'can add adjacent vertices to a new vertex' do
    v("a", "b", "c").adjacent_vertices.map(&:label).should =~ ["b", "c"]
  end

  it 'can be deep-duped so that a change in the original graph does not affect the duplicated graph' do
    v("a", "b", "c")
    v("b", "a")
    v("c", "a")

    duped = graph.deep_dup
    duped.vertex_for("a", "d")
    duped.vertex_for("d", "a")

    duped.vertex_for("a").adjacent_vertices.map(&:label).should =~ ["b", "c", "d"]
    graph.vertex_for("a").adjacent_vertices.map(&:label).should =~ ["b", "c"]
  end

  it 'keeps track of the edges as you add vertices' do
    v("a", "b", "c")
    v("b", "a")
    v("c", "a")

    graph.edges.map(&:vertex_labels).should =~ [["a", "b"], ["a", "c"]]
  end
end

