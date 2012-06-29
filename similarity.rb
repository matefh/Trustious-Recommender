#!/usr/bin/env ruby

require './linear_algebra.rb'
include LinearAlgebra

module Similarity
  def cosine_rule(vec1, vec2)
    dot = LinearAlgebra.dot_product(vec1, vec2)
    magn = LinearAlgebra.magnitude(vec1) * LinearAlgebra.magnitude(vec2)

    if magn > 1e-9
    then
      return dot / magn
    else
      return 0
    end
  end
end
