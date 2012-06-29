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
end
