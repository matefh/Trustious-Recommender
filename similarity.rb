#!/usr/bin/env ruby

require './linear_algebra.rb'
require './statistics.rb'
include LinearAlgebra, Statistics, Math

EPSILON = 1e-9

module Similarity
  def cosine_rule(vec1, vec2, weights=[])
    dot = Vector[Array.new(vec1.size, 1)]
    for weight in weights
      dot = dot * weight
    end
    num = (vec1 * vec2 * dot).sum
    magn = sqrt((dot * vec1.square).sum * (dot * vec2.square).sum)

    if magn > EPSILON
    then
      return num / magn
    else
      return 0
    end
  end


  def pearson_correlation(vec1, vec2, weights=[])
    return cosine_rule(vec1 - vec1.stats_mean, vec2 - vec2.stats_mean)
  end
end
