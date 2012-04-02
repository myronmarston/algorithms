require 'graph'

describe Vertex do
  it 'can be initialized with one label' do
    Vertex.new(stub, "a").labels.should eq(["a"])
  end

  it 'can be initialized with many label' do
    Vertex.new(stub, "a", "b").labels.should eq(["a", "b"])
    Vertex.new(stub, ["a", "b"]).labels.should eq(["a", "b"])
  end

  describe "#merge" do
    let(:graph) { stub.as_null_object }
    let(:a) { Vertex.new(graph, "a") }
    let(:b) { Vertex.new(graph, "b") }
    let(:c) { Vertex.new(graph, "c") }
    let(:d) { Vertex.new(graph, "d") }

    it "combines two vertices into one" do
      merged = a.merge(b)
      merged.graph.should be(graph)
      merged.labels.should =~ %w[ a b ]
    end

    it 'keeps the labels in a consistent order' do
      ab = a.merge(b)
      ba = b.merge(a)
      ab.labels.should eq(ba.labels)
    end

    it 'raises an error if given different graph objects' do
      g1 = Graph.new
      g2 = Graph.new

      v1 = Vertex.new(g1, "a")
      v2 = Vertex.new(g2, "b")

      expect { v1.merge(v2) }.to raise_error(ArgumentError)
      expect { v2.merge(v1) }.to raise_error(ArgumentError)
    end

    it 'can merge previously merged vertices' do
      ab = a.merge(b)
      cd = c.merge(d)

      ab.merge(cd).labels.should =~ %w[ a b c d ]
    end
  end
end

describe Edge do
  let(:graph) { stub.as_null_object }

  it 'puts the labels in consistent order' do
    e1 = Edge.new(graph, "a", "b")
    e2 = Edge.new(graph, "b", "a")
    e1.should eq(e2)
  end
end

describe Graph do
  let(:ab_graph) do
    Graph.new do |g|
      g.vertex "a", connected_to: "b"
      g.vertex "b", connected_to: "a"
    end
  end

  it 'de-dups edges during construction' do
    ab_graph.vertices.map(&:labels).should =~ [["a"], ["b"]]
    ab_graph.edges.map { |e| [e.vertex_label_1, e.vertex_label_2] }.should eq([["a", "b"]])
  end

  it 'does not allow further graph building once the initial construction is done' do
    expect { ab_graph.vertex "c", connected_to: "a" }.to raise_error
  end

  it 'can be built from a space/line delimited string' do
    graph = Graph.from_file_contents <<-EOS
      1 2 3
      2 1 4
      3 1 4
      4 2 3
    EOS

    graph.vertices.map(&:labels).flatten.should =~ %w[ 1 2 3 4 ]
    graph.edges.map(&:vertex_labels).should =~ [["1", "2"], ["1", "3"], ["2", "4"], ["3", "4"]]
  end

  it 'can read in a graph from a file' do
    graph = Graph.from_file("./min-cut-graph.txt")
    graph.should have(40).vertices
    graph.should have_at_least(70).edges
  end

  it 'can be deep-duped so a change in one graph does not affect the original' do
    g2 = ab_graph.deep_dup
    g2.contract_edge(g2.edges.first)
    g2.edges.size.should eq(0)
    ab_graph.edges.size.should eq(1)
  end

  describe "#edge_for" do
    it 'can find an edge' do
      edge = ab_graph.edge_for("a", "b")
      edge.vertex_label_1.should eq("a")
      edge.vertex_label_2.should eq("b")
    end

    it "returns nil when none can be found" do
      ab_graph.edge_for("a", "c").should be_nil
    end
  end

  describe "#contract_edge" do
    let(:graph) do
      Graph.new do |g|
        g.vertex "a", connected_to: "b"
        g.vertex "a", connected_to: "c"
        g.vertex "b", connected_to: "c"
        g.vertex "b", connected_to: "d"
        g.vertex "c", connected_to: "d"
        g.vertex "d", connected_to: "a"
      end
    end

    it "removes the edge" do
      edge = graph.edge_for("a", "b")
      graph.contract_edge(edge)
      graph.edge_for("a", "b").should be_nil
    end

    it 'merges the vertices' do
      edge = graph.edge_for("a", "b")
      graph.contract_edge(edge)
      graph.vertices.map(&:labels).should include(["a", "b"])
      graph.vertices.map(&:labels).should_not include("a", "b")
    end

    it 'removes self-loops' do
      edge = graph.edge_for("a", "b")
      graph.contract_edge(edge)

      edge = graph.edge_for("a", "c")
      graph.contract_edge(edge)
      graph.edge_for("b", "c").should be_nil
    end
  end
end

