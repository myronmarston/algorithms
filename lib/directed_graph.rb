Vertex = Struct.new(:graph, :label) do
  def initialize(graph, label)
    super(graph, label)
  end

  def outgoing_edges
    @outgoing_edges ||= []
  end

  def incoming_edges
    @incoming_edges ||= []
  end

  def to_s
    "#<V #{label}>"
  end
  alias inspect to_s
end

Edge = Struct.new(:tail, :head) do
  def initialize(tail, head)
    super
    tail.outgoing_edges << self
    head.incoming_edges << self
  end

  def to_s
    "<E #{tail.label} => #{head.label}>"
  end
  alias inspect to_s
end

class Graph
  def initialize
    @vertices = Hash.new do |hash, label|
      hash[label] = Vertex.new(self, label)
    end

    yield self if block_given?
  end

  def add_edge(tail, head)
    tail_v = @vertices[tail]
    head_v = @vertices[head]

    vertices << tail_v << head_v

    edges << Edge.new(tail_v, head_v)
  end

  def edges
    @edges ||= []
  end

  def vertices
    @vertices.values
  end

  def self.from_file(file)
    new do |g|
      File.open(file, 'r') do |f|
        lines = f.lines
        lines = yield(lines) if block_given?
        lines.each do |line|
          g.add_edge(*line.split(/\s+/).map(&:to_i))
        end
      end
    end
  end
end

