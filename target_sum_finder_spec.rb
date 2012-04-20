class TargetSumFinder
  def initialize(*values)
    @integer_count = Hash.new(0)
    values.each { |v| self << v }
  end

  def <<(number)
    @integer_count[number] += 1
  end

  def has_two_integers_that_sum_to?(sum)
    @integer_count.keys.any? do |x|
      if (x + x == sum)
        @integer_count[x] > 1
      else
        @integer_count.has_key?(sum - x)
      end
    end
  end
end

describe TargetSumFinder do
  let(:finder) { TargetSumFinder.new(3, 17, 6, 9, 8, 2, 2) }

  it "returns true if the list of numbers contains two entries that sum to the given target" do
    finder.should have_two_integers_that_sum_to(20)
    finder.should have_two_integers_that_sum_to(9)
    finder.should have_two_integers_that_sum_to(5)
  end

  it "returns false if there are not two numbers that sum to the given target" do
    finder.should_not have_two_integers_that_sum_to(21)
    finder.should_not have_two_integers_that_sum_to(7)
    finder.should_not have_two_integers_that_sum_to(1)
  end

  specify { finder.should have_two_integers_that_sum_to(4) }
  specify { finder.should_not have_two_integers_that_sum_to(34) }

  it "solves the homework problem" do
    finder = TargetSumFinder.new
    File.open("./integer_list.txt", "r") { |f| f.lines.each { |l| finder << l.strip.to_i } }
    results = [231552,234756,596873,648219,726312,981237,988331,1277361,1283379].map do |sum|
      finder.has_two_integers_that_sum_to?(sum) ? '1' : '0'
    end
    puts results.join("")
  end
end

