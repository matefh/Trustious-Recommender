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


  def pearson_correlation(vec1, vec2)
    average1 = 0
    average2 = 0
    vec1.each {|x| average1 += x}
    vec2.each {|x| average2 += x}
    if vec1.size != 0
    then
      average1 /= vec1.size.to_f
    end

    if vec2.size != 0
    then
      average2 /= vec2.size.to_f
    end
    return cosine_rule(vec1.map {|x| x - average1},
                       vec2.map {|x| x - average2})
  end


  def compute_expected_rating(rating_list, similarity_list)
    weighted_rating = LinearAlgebra.dot_product(rating_list, similarity_list)
    total_similarity = 0
    similarity_list.each {|similarity| total_similarity += similarity}
    if total_similarity.abs > 1e-9
    then
      return weighted_rating.to_f / total_similarity.to_f
    else
      return 0
    end
  end
end
