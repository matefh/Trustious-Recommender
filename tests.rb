#!/usr/bin/env ruby


require './linear_algebra.rb'
require './similarity.rb'
require 'test/unit'
include LinearAlgebra, Similarity


class Tests < Test::Unit::TestCase
  def test_dot_product
    val1 = LinearAlgebra.dot_product([1, 2, 3, 4], [5, 1, 2, 3])
    val2 = LinearAlgebra.dot_product([1, 6, 101, 2, 121], [-1, 2, 1, 3, -10007])
    val3 = LinearAlgebra.dot_product([], [])
    val4 = LinearAlgebra.dot_product([10000, 10000, 1000], [0, 0, 0])
    val5 = LinearAlgebra.dot_product([1, 2, 3, 4], [-12, -3, 2, 3])

    assert_equal(val1, 25, "The dot product should be equal to 25.")
    assert_equal(val2, -1210729, "The dot product should be equal to -1210729")
    assert_equal(val3, 0, "The vectors are empty.")
    assert_equal(val4, 0, "One of the vectors is 0.")
    assert_equal(val5, 0, "The vectors are orthogonal.")
  end


  def test_magnitude
    actual_magnitudes = [1230, 14, 1029203, 0].map {|x| Math.sqrt(x)}
    expected_magnitudes = Array.new
    expected_magnitudes << LinearAlgebra.magnitude([1, 2, 35])
    expected_magnitudes << LinearAlgebra.magnitude([-1, 3, -2])
    expected_magnitudes << LinearAlgebra.magnitude([5, -1007, 123])
    expected_magnitudes << LinearAlgebra.magnitude([])

    diff = actual_magnitudes.zip(expected_magnitudes)
    diff.map! {|magnitude| magnitude[0] - magnitude[1]}

    diff.each {|val| assert(val.abs < 1e-9)}
  end


  def test_magnitude_square
    actual_magnitudes = [1230, 14, 1029203, 0]
    expected_magnitudes = Array.new
    expected_magnitudes << LinearAlgebra.magnitude_squared([1, 2, 35])
    expected_magnitudes << LinearAlgebra.magnitude_squared([-1, 3, -2])
    expected_magnitudes << LinearAlgebra.magnitude_squared([5, -1007, 123])
    expected_magnitudes << LinearAlgebra.magnitude_squared([])

    diff = actual_magnitudes.zip(expected_magnitudes)
    diff.map! {|magnitude| magnitude[0] - magnitude[1]}

    diff.each {|val| assert_equal(val, 0)}
  end


  def test_cosine_rule
    users1 = [[1, 4, 5, 2, 1], [5, -1, 2, 4, 10], [42134, 123, 123], []]
    users2 = [[0, -4, 1, 2, 1], [51, 12, 4, -101, 123], [23, 1, 12], []]

    users1 << [123, 1007, 10007, 231]
    users2 << [123, 1007, 10007, 231]
    users1 << [123, 1007, 10007, 231]
    users2 << [-123, -1007, -10007, -231]
    users1 << [1, 2, 3, 4]
    users2 << [-12, -3, 2, 3]

    actual_values = [-0.18659, 0.53180899, 0.8873811, 0, 1, -1, 0]
    expected_values = users1.zip(users2).map {|x| Similarity.cosine_rule(x[0], x[1])}
    diff = actual_values.zip(expected_values).map {|sim| sim[0] - sim[1]}

    diff.each {|val| assert(val.abs < 1e-5)}
  end
end
