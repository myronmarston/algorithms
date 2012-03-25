class QuickSort
  def self.perform(array)
    new(array).sort(0, array.length - 1)
  end

  def self.comparisons_for(array)
    instance = new(array)
    instance.sort(0, array.length - 1)
    instance.comparison_count.tap do |c|
      raise "#{c} vs #{instance.raw_comparison_count}" unless c == instance.raw_comparison_count
    end
  end

  attr_reader :array, :comparison_count, :raw_comparison_count
  def initialize(array)
    @array = array.dup
    @comparison_count = 0
    @raw_comparison_count = 0
  end

  def sort(l, r)
    return array if l >= r
    @comparison_count += (r - l)

    final_pivot_index = partition(l, r)

    sort(l, final_pivot_index - 1)
    sort(final_pivot_index + 1, r)

    array
  end

private

  def choose_pivot(l, r)
    array[l]
  end

  def partition(l, r)
    pivot = choose_pivot(l, r)
    i = l + 1

    i.upto(r) do |j|
      @raw_comparison_count += 1
      next unless array[j] < pivot
      array[i], array[j] = array[j], array[i]
      i += 1
    end

    array[l], array[i - 1] = array[i - 1], array[l]
    return i - 1
  end
end

class QuickSortWithLastElementPivot < QuickSort
  def choose_pivot(l, r)
    array[r].tap do |pivot|
      array[l], array[r] = array[r], array[l]
    end
  end
end

class QuickSortWithMedianOfThreePivot < QuickSort
  def self.median_of_three_index(array, l, r)
    length = r - l + 1
    indices = [l, r, (length / 2.0).ceil - 1 + l]
    indices.sort_by! { |i| array[i] }
    indices[1]
  end

  def choose_pivot(l, r)
    index = self.class.median_of_three_index(array, l, r)
    array[index].tap do |pivot|
      array[l], array[index] = array[index], array[l]
    end
  end
end

if defined?(::RSpec)
  shared_examples_for "quick sort" do
    it 'sorts a list of integers properly' do
      described_class.perform([1, 6, 3, 2, 8, 4, 5, 7]).should eq([1, 2, 3, 4, 5, 6, 7, 8])
    end

    it 'counts the number of comparisons' do
      described_class.comparisons_for([]).should eq(0)
      described_class.comparisons_for([1]).should eq(0)
      described_class.comparisons_for([2, 1]).should eq(1)
    end

    0.upto(100) do |size|
      array = 1.upto(size).map { |_| rand(20) }
      it "sorts #{array} correctly" do
        described_class.perform(array).should eq(array.sort)
        described_class.comparisons_for(array) # should not raise an error
      end
    end
  end

  describe QuickSort do
    it_behaves_like "quick sort"
  end

  describe QuickSortWithLastElementPivot do
    it_behaves_like "quick sort"
  end

  describe QuickSortWithMedianOfThreePivot do
    it_behaves_like "quick sort"

    describe ".median_of_three_index" do
      specify do
        QuickSortWithMedianOfThreePivot.median_of_three_index([0, 1, 2], 0, 2).should eq(1)
      end

      specify do
        QuickSortWithMedianOfThreePivot.median_of_three_index([1, 0, 2], 0, 2).should eq(0)
      end

      specify do
        QuickSortWithMedianOfThreePivot.median_of_three_index([2, 0, 1], 0, 2).should eq(2)
      end

      specify do
        QuickSortWithMedianOfThreePivot.median_of_three_index([3, 0, 1, 2], 0, 3).should eq(3)
      end

      specify do
        QuickSortWithMedianOfThreePivot.median_of_three_index([2, 3, 1, 0], 0, 3).should eq(0)
      end

      specify do
        QuickSortWithMedianOfThreePivot.median_of_three_index([2, 1, 3, 0], 0, 3).should eq(1)
      end

      specify do
        QuickSortWithMedianOfThreePivot.median_of_three_index([4, 7, 1, 3, 6, 2, 5], 3, 6).should eq(6)
      end

      specify do
        QuickSortWithMedianOfThreePivot.median_of_three_index([4, 7, 1, 3, 6, 2, 5], 1, 5).should eq(3)
      end
    end
  end
end

if __FILE__ == $0
  array = File.read('QuickSort.txt').split("\n").map(&:to_i)
  puts "First element as Pivot: #{QuickSort.comparisons_for(array)}"
  puts "Last element as Pivot: #{QuickSortWithLastElementPivot.comparisons_for(array)}"
  puts "Median of Three elements as Pivot: #{QuickSortWithMedianOfThreePivot.comparisons_for(array)}"
end
