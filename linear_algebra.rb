#!/usr/bin/env ruby


module LinearAlgebra
  def dot_product(vec1, vec2, weight=nil)
    result = 0
    if weight.nil?
      weight = [1] * vec1.size
    end
    zipped_vector = vec1.zip(vec2, weight)
    for elem in zipped_vector
      prod_result = 1
      elem.each {|x| prod_result *= x}
      result += prod_result
    end
    return result
  end


  def magnitude_squared(vec, weight=nil)
    return dot_product(vec, vec, weight)
  end


  def magnitude(vec, weight=nil)
    return Math.sqrt(magnitude_squared(vec, weight))
  end


  def vector_add(vec1, vec2)
    return vec1.zip(vec2).map {|elem| elem[0] + elem[1]}
  end


  def vector_scalar_mult(vec, value)
    return vec.map {|elem| elem * value}
  end


  def vector_subtract(vec1, vec2)
    return vec1.zip(vec2).map {|elem| elem[0] - elem[1]}
  end
end
