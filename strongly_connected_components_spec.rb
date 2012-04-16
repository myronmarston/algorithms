require 'directed_graph'

class DepthFirstSearch
  class Tracker
    attr_reader :search_order, :scc

    def initialize(graph_size)
      @search_order = Array.new(graph_size)
      @search_order_count = 0
      @scc = []
    end

    def done_with(vertex)
      @search_order_count += 1
      @search_order[-@search_order_count] = vertex
    end
  end

  def initialize(graph)
    @graph = graph
  end

  def process_vertex(vertex, tracker = Tracker.new(@graph.vertices.size), edge_type = :outgoing_edges, follow_edge_type = :head, &block)
    unless vertex.explored?
      yield vertex if block_given?
      vertex.explored = true
      tracker.scc << vertex
    end

    vertex.send(edge_type).each do |edge|
      next_vertex = edge.send(follow_edge_type)
      unless next_vertex.explored?
        return :follow, next_vertex
      end
    end

    return :done, nil
  end

  def search_from(starting_vertex, tracker = Tracker.new(@graph.vertices.size), edge_type = :outgoing_edges, follow_edge_type = :head, &block)
    stack = []
    vertex = starting_vertex

    loop do
      result, next_vertex = process_vertex(vertex, tracker, edge_type, follow_edge_type, &block)

      if result == :follow
        stack.push(vertex)
        vertex = next_vertex
      elsif result == :done
        tracker.done_with(vertex)
        vertex = stack.pop
        break if vertex.nil?
      end
    end
  end

  def find_scc_search_order
    tracker = Tracker.new(@graph.vertices.size)

    @graph.vertices.each do |vertex|
      next if vertex.explored?
      search_from(vertex, tracker, :incoming_edges, :tail)
    end

    tracker.search_order
  end

  def find_scc_sizes
    search_order = find_scc_search_order
    search_order.each { |v| v.explored = false }

    sizes = []
    search_order.each do |vertex|
      next if vertex.explored?
      tracker = Tracker.new(@graph.vertices.size)
      search_from(vertex, tracker)
      sizes << tracker.scc.size
    end

    sizes
  end
end

describe DepthFirstSearch do
  let(:small_g) { Graph.from_file("./scc-test-cases/small.txt") }
  let(:vertex_7) { small_g.vertices.find { |v| v.label == 7 } }
  let(:searcher) { DepthFirstSearch.new(small_g) }

  it 'follows edges and visits vertices' do
    yielded = []
    searcher.search_from(vertex_7) { |v| yielded << v.label }
    yielded.should =~ [7, 8, 9, 10]
  end

  describe "#find_scc_search_order" do
    let(:graph) { Graph.new { |g|
      g.add_edge 1, 4
      g.add_edge 2, 8
      g.add_edge 3, 6
      g.add_edge 4, 7
      g.add_edge 5, 2
      g.add_edge 6, 9
      g.add_edge 7, 1
      g.add_edge 8, 6
      g.add_edge 9, 7
    } }

    it "finds the proper ordering to run an SCC search (i.e. the 1st pass of Kosaraju's two-pass algorithm)" do
      DepthFirstSearch.new(graph).find_scc_search_order.map(&:label).should == [1, 7, 9, 6, 8, 2, 5, 3, 4]
    end
  end

  describe "#find_scc_sizes" do
    it 'finds all the sccs' do
      searcher.find_scc_sizes.should =~ [3, 3, 4]
    end
  end

  it 'works on the assignment input' do
    graph = Graph.from_file("./scc-test-cases/assignment.txt") { |lines| lines.first(10000000) }
    puts "Graph built..."
    searcher = DepthFirstSearch.new(graph)
    sizes = searcher.find_scc_sizes.sort.reverse
    puts sizes.first(10).inspect
  end
end

