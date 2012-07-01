#!/usr/bin/env ruby

require "./similarity.rb"
include Similarity

module ItemToItem
  
  THRESHOLD = 0.5
  
  def calculate_similarity(vec1, vec2)
    return Similarity.cosine_rule(vec1, vec2)
  end

end
