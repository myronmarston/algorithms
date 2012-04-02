require 'graph'

class MinCut
  attr_reader :graph
  def initialize(graph)
    @graph = graph
  end

  def num_iterations
    @num_iterations ||= ((graph.vertices.size ** 2) * Math.log(graph.vertices.size)).ceil
  end

  def calculate
    results = num_iterations.ceil.times.map do
      copy = graph.deep_dup
      copy.contract_edge(copy.edges.sample) while copy.vertices.size > 2
      copy.edges.size
    end

    results.min
  end
end

describe MinCut do
  describe "#num_iterations" do
    it 'returns 23 for 4' do
      graph = Graph.new do |g|
        4.times { |i| g.vertex i }
      end

      MinCut.new(graph).num_iterations.should eq(23)
    end

    it 'returns 134 for 8' do
      graph = Graph.new do |g|
        8.times { |i| g.vertex i }
      end

      MinCut.new(graph).num_iterations.should eq(134)
    end
  end

  describe "#calculate" do
    it 'works on a test case of 4 vertices' do
      graph = Graph.from_file_contents <<-EOS
        1 2 3
        2 1 4
        3 1 4
        4 2 3
      EOS

      MinCut.new(graph).calculate.should eq(2)
    end

    it 'works on a test case of 8 vertices' do
      graph = Graph.from_file_contents <<-EOS
        1 2 3 7
        2 1 3 7
        3 1 2 4 7
        4 3 5 6 8
        5 4 6 8
        6 4 5 8
        7 1 2 3
        8 4 5 6
      EOS

      MinCut.new(graph).calculate.should eq(1)
    end

    it 'works on the example from the class' do
      graph = Graph.from_file('min-cut-graph.txt')
      mc = MinCut.new(graph)

      mc.calculate.should eq(3)
    end
  end
end

