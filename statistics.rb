#!/usr/bin/env ruby

module Statistics
  def variance(vec)
    n = vec.size
    res = 0.0

    if n > 0
    then
      avg = 0.0
      sq = 0.0
      vec.each {|x|
        avg += x
        sq += x * x
      }
      sq /= n
      avg /= n
      res = sq - avg * avg
    end

    return res
  end


  def standard_deviation(vec)
    return Math.sqrt(variance(vec))
  end


  def average(vec)
    n = vec.size
    res = 0.0
    if n > 0
    then
      vec.each {|x|
        res += x
      }
      res /= n
    end

    return res
  end
end
