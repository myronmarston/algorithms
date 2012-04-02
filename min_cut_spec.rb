require 'set'

class Graph
  attr_reader :edges

  def initialize
    @vertices = {}
    @edges = Set.new
  end

  def vertices
    @vertices.values
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

  def random_edge
    edges.to_a.sample
  end

  def contract_random_edge
    graph_building_done!
    edge = random_edge
    edges.delete(edge)

    @vertices.delete edge.vertex_1
    @vertices.delete edge.vertex_2

    @vertices << edge.vertex_1.merge(edge.vertex_2)
  end

private

  def graph_building_done!
    @vertices = Set.new(@vertices.values)
    extend CompletelyBuilt
  end

  module CompletelyBuilt
    def vertices
      @vertices.to_a
    end
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

module VertexMerger
  def merge(vertex)
    sorted_vertices = (vertices + [vertex]).sort_by(&:label)
    MergedVertex.new(sorted_vertices)
  end
end

Vertex = Struct.new(:label) do
  include VertexMerger

  def vertices
    [self]
  end

  def adjacent_vertices
    @adjacent_vertices ||= Set.new
  end
end

MergedVertex = Struct.new(:vertices) do
  include VertexMerger
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

describe Vertex, '#merge' do
  it 'produces a new vertex with both vertices, sorted by label' do
    v1 = Vertex.new("a")
    v2 = Vertex.new("b")

    v1.merge(v2).vertices.should eq([v1, v2])
    v2.merge(v1).vertices.should eq([v1, v2])
  end

  it 'can merge repeatedly' do
    v1 = Vertex.new("a")
    v2 = Vertex.new("b")
    v3 = Vertex.new("c")

    v2.merge(v1).merge(v3).vertices.should eq([v1, v2, v3])
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

  it 'can find a random edge' do
    v("a", "b", "c")
    v("b", "a")
    v("c", "a")

    selected_edges = 10.times.map { graph.random_edge }.uniq
    selected_edges.should have(2).edges
  end

  describe "#contract_random_edge" do
    def stub_random_edge(l1, l2)
      edge = graph.edges.to_a.find { |e| e.vertex_1.label == l1 && e.vertex_2.label == l2 }
      graph.stub(:random_edge => edge)
    end

    before do
      v("a", "b", "c")
      v("b", "a")
      v("c", "a")
    end

    it 'correctly removes edges' do
      stub_random_edge "a", "b"
      graph.contract_random_edge
      graph.edges.map(&:vertex_labels).should == [["a", "c"]]
    end

    it 'correctly merges vertices' do
      merged_vertex = MergedVertex.new([v("a"), v("b")])
      c = v("c")
      stub_random_edge "a", "b"
      graph.should have(3).vertices

      graph.contract_random_edge
      graph.should have(2).vertices
      graph.vertices.should =~ [merged_vertex, c]
    end
  end
end

