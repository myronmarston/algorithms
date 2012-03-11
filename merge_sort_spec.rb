class Array
  def split
    mid = size / 2
    left = slice(0, mid)
    right = slice(mid, (size - mid))
    return left, right
  end
end

class MergeSort
  def self.perform(array)
    return array if array.size < 2
    left, right = array.split
    merge(perform(left), perform(right))
  end

  def self.merge(a1, a2)
    result = []

    while a1.any? && a2.any?
      if a1.first < a2.first
        result << a1.shift
      else
        result << a2.shift
      end
    end

    result + a1 + a2
  end
end

describe MergeSort do
  it 'sorts a list of integers properly' do
    MergeSort.perform([1, 6, 3, 2, 8, 4, 5, 7]).should eq([1, 2, 3, 4, 5, 6, 7, 8])
  end

  0.upto(100) do |size|
    array = 1.upto(size).map { |_| rand(20) }
    it "sorts #{array} correctly" do
      MergeSort.perform(array).should eq(array.sort)
    end
  end
end
