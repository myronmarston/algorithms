class Array
  def split
    mid = size / 2
    left = slice(0, mid)
    right = slice(mid, (size - mid))
    return left, right
  end
end

class CountInversions
  def self.perform(array)
    recursively_perform(array).last
  end

  def self.recursively_perform(array)
    return array, 0 if array.size < 2

    left, right = array.split
    left_merged, left_count = recursively_perform(left)
    right_merged, right_count = recursively_perform(right)
    merged, count = merge_and_count(left_merged, right_merged)

    return merged, (left_count + right_count + count)
  end

  def self.merge_and_count(a1, a2)
    result, count = [], 0

    while a1.any? && a2.any?
      if a1.first < a2.first
        result << a1.shift
      else
        count += a1.size
        result << a2.shift
      end
    end

    merged = result + a1 + a2
    return merged, count
  end
end

if defined?(::RSpec)
  describe CountInversions do
    {
      [1, 2] => 0,
      [2, 1] => 1,
      [3, 1, 2] => 2,
      [3, 2, 1] => 3,
      [7, 1, 3, 6, 2, 5, 8, 4] => 12,
      [2, 6, 3, 4, 1, 5] => 7
    }.each do |array, count|
      it "counts #{count} inversions in #{array.inspect}" do
        CountInversions.perform(array).should eq(count)
      end
    end
  end
end

if __FILE__ == $0
  array = STDIN.read.split("\n").map(&:to_i)
  puts CountInversions.perform(array)
end
