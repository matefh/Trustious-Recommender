#!/usr/bin/env ruby

require './linear_algebra.rb'
require './statistics.rb'
include LinearAlgebra, Statistics

EPSILON = 1e-9

module Similarity
  def cosine_rule(vec1, vec2, weight=nil)
    dot = dot_product(vec1, vec2, weight)
    magn = magnitude(vec1, weight) * magnitude(vec2, weight)

    if magn > EPSILON
    then
      return dot / magn
    else
      return 0
    end
  end


  def pearson_correlation(vec1, vec2, weight=nil)
    average1 = average(vec1)
    average2 = average(vec2)
    return cosine_rule(vec1.map {|x| x - average1},
                       vec2.map {|x| x - average2}, weight)
  end


  def pythagorean_distance(vec1, vec2)
    pythagorean = 0
    pythagorean += magnitude_squared(vec1)
    pythagorean += magnitude_squared(vec2)
    return 2 * dot_product(vec1, vec2) / pythagorean
  end
end
