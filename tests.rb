#!/usr/bin/env ruby


require './linear_algebra.rb'
require './similarity.rb'
require './recommender.rb'
require 'test/unit'
include LinearAlgebra, Similarity, ItemToItem

class Tests < Test::Unit::TestCase

  def test_online_stage
    ItemToItem.offline_stage("ratings.in", "users.in", "movies.in");
    recommended_movies1 = ItemToItem.online_stage(1, 1)
    recommended_movies2 = ItemToItem.online_stage(2, 1)
    recommended_movies3 = ItemToItem.online_stage(3, 2).sort

    assert_equal([3], recommended_movies1, "The recommended movies are wrong")
    assert_equal([1], recommended_movies2, "The recommended movies are wrong")
    assert_equal([], recommended_movies3, "The recommended movies are wrong")
  end

  def test_n_expected_rating(number_of_ratings = 2000)
    input = IO.readlines("u.data")
    hidden_rating = Array.new(input.length) {0}
    user_movie_pair = Array.new(number_of_ratings) {[]}
    bad_lines = Array.new(0)

    for i in 0...number_of_ratings
      random = rand(input.length)
      line = input[random]
      line = line.split(" ")
      user_movie_pair[i] = line.map {|x| x.to_i}
      hidden_rating[random] = 1
      bad_lines.push(random)
    end
    ItemToItem.offline_stage("u.data", "u.info", bad_lines)

    result_with_rounding = 0
    result_without_rounding = 0
    error = Array.new(6) {0}
    expectations_generated = Array.new(0)
    user_movie_pair.each{ |test|
      one_expectation = test.clone
      rating = ItemToItem.expected_rating(test[0], test[1])
      result_without_rounding += (rating - test[2]) * (rating - test[2])
      one_expectation.push(rating)
      rating = (rating + 0.5).to_i
      one_expectation.push(rating)
      result_with_rounding += (rating - test[2]) * (rating - test[2])
      error[(rating - test[2]).abs] += 1
      expectations_generated.push(one_expectation)
    }
    result_with_rounding = Math.sqrt( result_with_rounding.to_f / number_of_ratings.to_f )
    result_without_rounding = Math.sqrt( result_without_rounding.to_f / number_of_ratings.to_f )
    print "Error with rounding = ", result_with_rounding, " " , "Error without rounding = " , result_without_rounding , " ", error.inspect, "\n"

    File.open("Debug Log.txt" , "w") do |out|
      out.print "Similarity Table:\n","---------------------\n"
      for i in 1...$number_of_movies
        for j in 1...$number_of_movies
          if $movies_similarity[i][j].nil?
            out.print "nil", " " * 14
          else
            out.print "#{sprintf "%15.8f" ,$movies_similarity[i][j]} "
          end
        end
        out.print "\n"
      end
      out.print "*" * 100, "\n"
      for i in 1...$number_of_movies
        out.print $neighborhood[i].inspect, "\n"
      end
      out.print "*" * 100, "\n"
      expectations_generated.each{ |x|
        out.print x.inspect, "\n"
      }
    end

  end

  def test_dot_product
    val1 = LinearAlgebra.dot_product([1, 2, 3, 4], [5, 1, 2, 3])
    val2 = LinearAlgebra.dot_product([1, 6, 101, 2, 121], [-1, 2, 1, 3, -10007])
    val3 = LinearAlgebra.dot_product([], [])
    val4 = LinearAlgebra.dot_product([10000, 10000, 1000], [0, 0, 0])
    val5 = LinearAlgebra.dot_product([1, 2, 3, 4], [-12, -3, 2, 3])

    assert_equal(25, val1, "The dot product should be equal to 25.")
    assert_equal(-1210729, val2, "The dot product should be equal to -1210729")
    assert_equal(0, val3, "The vectors are empty.")
    assert_equal(0, val4, "One of the vectors is 0.")
    assert_equal(0, val5, "The vectors are orthogonal.")
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

    diff.each {|val| assert_equal(0, val)}
  end


  def test_vector_addition
    vec1 = [[1, 2, 3, 4], [5, 1, -123, 1237], [100007, 10006], []]
    vec2 = [[5, 1, 2, 3], [0, 0, 1000007, 21], [-10000000007, 1000000009], []]

    actual_results = [[6, 3, 5, 7], [5, 1, 999884, 1258],
                      [-9999900000, 1000010015], []]
    expected_results = vec1.zip(vec2).map {|vec| vector_add(vec[0], vec[1])}

    results = actual_results.zip(expected_results)

    results.each {|val| assert_equal(val[0], val[1])}
  end


  def test_vector_scaling
    vec = [[1, 2, 3, 4], [5, 1, -123, 1237], [100007, 10006], []]
    scale = [2, -4, 12, 5]

    actual_results = [[2, 4, 6, 8], [-20, -4, 492, -4948],
                      [1200084, 120072], []]
    expected_results = vec.zip(scale).map {|param| vector_scalar_mult(param[0], param[1])}

    results = actual_results.zip(expected_results)

    results.each {|val| assert_equal(val[0], val[1])}
  end


  def test_vector_subtraction
    vec1 = [[1, 2, 3, 4], [5, 1, -123, 1237], [100007, 10006], []]
    vec2 = [[-5, -1, -2, -3], [0, 0, -1000007, -21], [10000000007, -1000000009], []]

    actual_results = [[6, 3, 5, 7], [5, 1, 999884, 1258],
                      [-9999900000, 1000010015], []]
    expected_results = vec1.zip(vec2).map {|vec| vector_subtract(vec[0], vec[1])}

    results = actual_results.zip(expected_results)

    results.each {|val| assert_equal(val[0], val[1])}
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


  def test_pearson_correlation
    users1 = [[1, 4, 5, 2, 1], [5, -1, 2, 4, 10], [42134, 123, 123], []]
    users2 = [[0, -4, 1, 2, 1], [51, 12, 4, -101, 123], [23, 1, 12], []]

    users1 << [123, 1007, 10007, 231]
    users2 << [123, 1007, 10007, 231]
    users1 << [123, 1007, 10007, 231]
    users2 << [-123, -1007, -10007, -231]
    users1 << [1, 2, 3, 4]
    users2 << [-12, -3, 2, 3]

    actual_values = [-0.352089, 0.54511, 0.8660254, 0, 1, -1, 0.9415544]
    expected_values = users1.zip(users2).map {|x| Similarity.pearson_correlation(x[0], x[1])}
    diff = actual_values.zip(expected_values).map {|sim| sim[0] - sim[1]}

    diff.each {|val| assert(val.abs < 1e-5)}
  end


  def test_compute_expected_rating
    ratings = [[1, 4, -1, 2, 0], [1, 2, 4, 0], [5, 5, 5, 5, 5], [0, 0, 1, -1, 0], []]
    similarities = [[0.2, 0.1, 0.7, 0, 1], [0.3, -0.2, 0.4, 1], [0.1, 0.1, 0.2, 0.1, 0.1], [0.7, 0.7, 0.5, 0.6, 0.1], []]
    expected_values = ratings.zip(similarities).map {|param| compute_expected_rating(param[0], param[1])}
    actual_values = [-0.0499999, 1.0, 5.0, -0.0384615, 0]

    diff = actual_values.zip(expected_values).map {|sim| sim[0] - sim[1]}

    diff.each {|val| assert(val.abs < 1e-5)}
  end
end
