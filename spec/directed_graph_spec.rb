require 'directed_graph'

describe Vertex do
  it 'can be initialized with a label' do
    Vertex.new(stub, "a").label.should eq("a")
  end
end

describe Edge do
  let(:graph) { stub.as_null_object }
  let(:a)     { Vertex.new(graph, "a") }
  let(:b)     { Vertex.new(graph, "b") }

  it 'has a tail vertex' do
    Edge.new(a, b).tail.should be(a)
  end

  it 'has a head vertex' do
    Edge.new(a, b).head.should be(b)
  end

  it "adds itself to the tail vertex's outgoing edges list" do
    a.outgoing_edges.should eq([])
    b.outgoing_edges.should eq([])
    edge = Edge.new(a, b)
    a.outgoing_edges.should eq([edge])
    b.outgoing_edges.should eq([])
  end

  it "adds itself to the head vertex's incoming edges list" do
    a.incoming_edges.should eq([])
    b.incoming_edges.should eq([])
    edge = Edge.new(a, b)
    a.incoming_edges.should eq([])
    b.incoming_edges.should eq([edge])
  end
end

describe Graph do
  it "can be built" do
    g = Graph.new do |g|
      g.add_edge("a", "b")
    end

    g.edges.size.should eq(1)
    edge = g.edges.first
    edge.tail.label.should eq("a")
    edge.head.label.should eq("b")

    g.vertices.map(&:label).should =~ ["a", "b"]
  end

  it "de-dups vertices" do
    g = Graph.new do |g|
      g.add_edge("a", "b")
      g.add_edge("b", "c")
      g.add_edge("c", "a")
    end

    g.should have(3).edges
    g.vertices.map(&:label).should =~ ["a", "b", "c"]
  end

  it "can be built from a text file of edges" do
    g = Graph.from_file("scc-test-cases/small.txt")
    g.should have(23).edges
    g.should have(10).vertices
  end
end

