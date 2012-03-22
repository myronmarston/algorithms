class KWayMerge
  def self.perform(arrays)
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

describe KWayMerge do
  2.upto(2) do |k|
    2.upto(2) do |n|
      it "merges #{k} arrays of #{n} elements each correctly" do
        numbers = 1.upto(k * n).to_a
        arrays = numbers.shuffle.each_slice(n).to_a
        arrays.map(&:sort!)

        KWayMerge.perform(arrays).should eq(numbers)
      end
    end
  end
end

