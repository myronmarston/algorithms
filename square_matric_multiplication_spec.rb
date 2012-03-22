class SquareMatrixMultiplier
  def self.multiply(m1, m2)
  end
end

describe SquareMatrixMultiplier do
  it 'multiplies a 2x2 matrix properly' do
    m1 = [[1, 2],
          [3, 4]]

    m2 = [[5, 6],
          [7, 8]]

    expected = [[19, 22],
                [43, 56]]

    SquareMatrixMultiplier.multiply(m1, m2).should eq(expected)
  end
end
