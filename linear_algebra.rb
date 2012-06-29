#!/usr/bin/env ruby


module LinearAlgebra
  def dot_product(vec1, vec2)
    result = 0
    zipped_vector = vec1.zip(vec2)
    for elem in zipped_vector
      prod_result = 1
      elem.each {|x| prod_result *= x}
      result += prod_result
    end
    return result
  end


  def magnitude_squared(vec)
    return dot_product(vec, vec)
  end


  def magnitude(vec)
    return Math.sqrt(magnitude_squared(vec))
  end
end
