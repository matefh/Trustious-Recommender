#!/usr/bin/env ruby

require './linear_algebra.rb'
require './similarity.rb'
require './recommender.rb'
require './statistics.rb'
require './input.rb'
require 'test/unit'
require 'gsl'
include LinearAlgebra, Similarity, ItemToItem, Statistics, Input, UserToUser, SVD

class Tests < Test::Unit::TestCase

  RAND_EXP = 84179
  RAND_CNST = 61283
  RAND_MOD = 75134177
  $rand_rec = 10007
  TEST_USERBASED = false
  FOLDS = 5


  def my_rand(last)
    $rand_rec = ($rand_rec * RAND_EXP + RAND_CNST) % RAND_MOD
    return $rand_rec % last
  end


  def test_online_stage
    set_alpha(2)
    if TEST_USERBASED
    then
      UserToUser.offline_stage_userbased("sample.data")
      recommended_movies = UserToUser.online_stage_userbased(1, 1)
      error = sprintf "%s\n%s\n", $users_neighborhood.inspect, $users_similarity.inspect
    else
      ItemToItem.offline_stage_itembased("sample.data")
      recommended_movies = ItemToItem.online_stage_itembased(1, 1)
      error = sprintf "%s\n%s\n", $movies_neighborhood.inspect, $movies_similarity.inspect
    end
    assert_equal([5], recommended_movies, error)
  end


  def test_precomputation
    if TEST_USERBASED
    then
      Input.precompute_userbased('train.data')
      total_size = 0
      $users_similarity.each {|adj| total_size += adj.size}
      assert_equal(total_size, IO.readlines('Precomputed_user_data.txt').size)
      assert(File.delete('Precomputed_user_data.txt'))
    else
      Input.precompute_itembased('train.data')
      total_size = 0
      $movies_similarity.each {|adj| total_size += adj.size}
      assert_equal(total_size, IO.readlines('Precomputed_item_data.txt').size)
      assert(File.delete('Precomputed_item_data.txt'))
    end
  end

=begin
  def test_cross_validation(infile = "train.data", folds = FOLDS)
    seperator = "-----------------------------"
    input_lines = IO.readlines(infile)
    n_users = input_lines[0].split(" ")[0].to_i
    n_items = input_lines[0].split(" ")[1].to_i
    n_ratings = input_lines.size - 1
    result = [0.0, 0.0]
    taken = 0
    for test_index in 1..folds
      ratings_to_take = (n_ratings - taken) / (folds + 1 - test_index)
      train_file = File.open("training_set.data", "w")
      test_file = File.open("testing_set.data", "w")
      train_file.printf "%d %d\n",  n_users, n_items
      for rating_index in 1..n_ratings
        if rating_index < taken + 1 or rating_index > taken + ratings_to_take
          train_file.print input_lines[rating_index]
        else
          test_file.print input_lines[rating_index]
        end
      end
      train_file.close
      test_file.close
      taken = taken + ratings_to_take
      printf "\nTest Number: %d, Fold Size : %d\n%s\n", test_index, ratings_to_take, seperator
      test_result = test_n_expected_rating("training_set.data", "testing_set.data")
      #test_result = test_svd("training_set.data", "testing_set.data")
      printf "%s\n", seperator
      result[0] = result[0] + test_result[0]
      result[1] = result[1] + test_result[1]
    end
    assert_equal(n_ratings, taken)
    File.delete "training_set.data"
    File.delete "testing_set.data"
    result[0] = result[0] / folds.to_f
    result[1] = result[1] / folds.to_f
    printf "\n\nAverage Error for the cross validation testing\n%s\nError with rounding = %s, Error without rounding = %s\n%s\n", seperator, result[1].to_s, result[0].to_s, seperator
    printf "%d-fold Cross Validation Ended\n\n", folds
  end
=end


  def test_n_expected_rating(train_file = "train.data", test_file = "test.data")
    if TEST_USERBASED
    then
      UserToUser.offline_stage_userbased(train_file)
    else
      ItemToItem.offline_stage_itembased(train_file)
    end

    result_with_rounding = 0
    result_without_rounding = 0
    error = Array.new(8) {0}
    expectations_generated = Array.new(0)
    File.open(test_file, "r").each_line{ |line|
      parse = line.split(" ")
      user = parse[0].to_i
      movie = parse[1].to_i
      correct_rating = parse[2].to_i

      one_expectation = [user, movie]
      one_expectation.push(correct_rating)
      if TEST_USERBASED
      then
        rating = UserToUser.expected_rating_userbased(user, movie)
      else
        rating = ItemToItem.expected_rating_itembased(user, movie)
      end
      result_without_rounding += (rating - correct_rating) * (rating - correct_rating)
      one_expectation.push(rating)
      rating = (rating + 0.5).to_i
      one_expectation.push(rating)
      result_with_rounding += (rating - correct_rating) * (rating - correct_rating)
      error[(rating - correct_rating).abs] += 1
      expectations_generated.push(one_expectation)
    }
    result_with_rounding = Math.sqrt( result_with_rounding.to_f / expectations_generated.size.to_f )
    result_without_rounding = Math.sqrt( result_without_rounding.to_f / expectations_generated.size.to_f )
    #print "Error with rounding = ", result_with_rounding, ",\n" , "Error without rounding = " , result_without_rounding , ",\nNumber of ratings of absolute difference [0, 1, 2, 3, 4, 5] ", error.inspect, ",\n"
    printf "\nError with rounding = %s,\nError without rounding = %s,
            \nNumber of ratings of absolute differences %s %s\n",
            result_with_rounding.to_s, result_without_rounding.to_s,
            Array(0...error.size).inspect, error.inspect
    return [result_without_rounding, result_with_rounding]
  end


=begin
  def test_cross_validation_svd
    for lam in [0.001, 0.005, 0.1, 0.2, 0.25]
      for gamma in [0.0001, 0.001, 0.005, 0.01]
        for dim in 1..5
          printf "Dimensionality = %d, Gamma = %s, Lambda = %s\n", dim, gamma.to_s, lam.to_s
          set_dimensionality(dim)
          set_learning_rate(gamma)
          set_regulizer(lam)
          test_cross_validation
          printf "\n\n"
        end
      end
    end
  end


  def test_svd(train_file = "train.data", test_file = "test.data")
    SVD.offline_stage_svd(train_file)
    result_with_rounding = 0
    result_without_rounding = 0
    error = Array.new(8) {0}
    expectations_generated = Array.new(0)
    File.open(test_file, "r").each_line{ |line|
      parse = line.split(" ")
      user = parse[0].to_i
      movie = parse[1].to_i
      correct_rating = parse[2].to_i

      rating = expected_rating_svd(user, movie)
      one_expectation = [user, movie]
      one_expectation.push(correct_rating)
      result_without_rounding += (rating - correct_rating) * (rating - correct_rating)
      one_expectation.push(rating)
      rating = (rating + 0.5).to_i
      one_expectation.push(rating)
      result_with_rounding += (rating - correct_rating) * (rating - correct_rating)
      if (rating - correct_rating).abs < 8
        error[(rating - correct_rating).abs] += 1
      end
      expectations_generated.push(one_expectation)
    }
    result_with_rounding = Math.sqrt( result_with_rounding.to_f / expectations_generated.size.to_f )
    result_without_rounding = Math.sqrt( result_without_rounding.to_f / expectations_generated.size.to_f )
    printf "Error with rounding = %s, Error without rounding = %s,
            \nNumber of ratings of absolute differences %s %s\n",
            result_with_rounding.to_s, result_without_rounding.to_s,
            Array(0...error.size).inspect, error.inspect
    return [result_without_rounding, result_with_rounding]
  end
=end


=begin
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
=end


  def test_cosine_rule
    users1 = [[1, 4, 5, 2, 1], [5, -1, 2, 4, 10], [42134, 123, 123]]
    users2 = [[0, -4, 1, 2, 1], [51, 12, 4, -101, 123], [23, 1, 12]]

    users1 << [123, 1007, 10007, 231]
    users2 << [123, 1007, 10007, 231]
    users1 << [123, 1007, 10007, 231]
    users2 << [-123, -1007, -10007, -231]
    users1 << [1, 2, 3, 4]
    users2 << [-12, -3, 2, 3]

    actual_values = [-0.18659, 0.53180899, 0.8873811, 1, -1, 0]
    expected_values = users1.zip(users2).map {|x| Similarity.cosine_rule(Vector[x[0]], Vector[x[1]])}
    #puts actual_values.inspect, expected_values.inspect
    diff = actual_values.zip(expected_values).map {|sim| sim[0] - sim[1]}

    diff.each {|val| assert(val.abs < 1e-5)}
  end


  def test_pearson_correlation
    users1 = [[1, 4, 5, 2, 1], [5, -1, 2, 4, 10], [42134, 123, 123]]
    users2 = [[0, -4, 1, 2, 1], [51, 12, 4, -101, 123], [23, 1, 12]]

    users1 << [123, 1007, 10007, 231]
    users2 << [123, 1007, 10007, 231]
    users1 << [123, 1007, 10007, 231]
    users2 << [-123, -1007, -10007, -231]
    users1 << [1, 2, 3, 4]
    users2 << [-12, -3, 2, 3]

    actual_values = [-0.352089, 0.54511, 0.8660254, 1, -1, 0.9415544]
    expected_values = users1.zip(users2).map {|x| Similarity.pearson_correlation(Vector[x[0]], Vector[x[1]])}
    diff = actual_values.zip(expected_values).map {|sim| sim[0] - sim[1]}

    diff.each {|val| assert(val.abs < 1e-5)}
  end


  def test_compute_expected_rating
    ratings = [[1, 4, -1, 2, 0], [1, 2, 4, 0], [5, 5, 5, 5, 5], [0, 0, 1, -1, 0]]
    similarities = [[0.2, 0.1, 0.7, 0, 1], [0.3, -0.2, 0.4, 1], [0.1, 0.1, 0.2, 0.1, 0.1], [0.7, 0.7, 0.5, 0.6, 0.1]]
    expected_values = ratings.zip(similarities).map {|param| compute_expected_rating(Vector[param[0]], Vector[param[1]])}
    actual_values = [-0.0499999, 0.78947, 5.0, -0.0384615]

    diff = actual_values.zip(expected_values).map {|sim| sim[0] - sim[1]}
    diff.each {|val| assert(val.abs < 1e-5)}
  end


=begin
  def test_standard_deviation
    values = [[5, 1, 2, 5, 7], [3, 3, 3, 3], [6, 11, 100, 2, 3], [4, 1, 6], []]
    actual_std = [2.1908902300206643, 0.0, 37.92940811560339, 2.0548046676563256, 0]
    expected_std = values.map {|x| Statistics.standard_deviation(x)}

    diff = actual_std.zip(expected_std).map {|sim| sim[0] - sim[1]}

    diff.each {|val| assert(val.abs < 1e-5)}
  end


  def test_variance
    values = [[5, 1, 2, 5, 7], [3, 3, 3, 3], [6, 11, 100, 2, 3], [4, 1, 6], []]
    actual_var = [4.8, 0.0, 1438.6399999999999, 4.222222222222222, 0]
    expected_var = values.map {|x| Statistics.variance(x)}

    diff = actual_var.zip(expected_var).map {|sim| sim[0] - sim[1]}

    diff.each {|val| assert(val.abs < 1e-5)}
  end


  def test_average
    values = [[5, 1, 2, 5, 7], [3, 3, 3, 3], [6, 11, 100, 2, 3], [4, 1, 6], []]
    actual_avg = [4, 3, 24.4, 3.6666667, 0]
    expected_avg = values.map {|x| Statistics.average(x)}

    diff = actual_avg.zip(expected_avg).map {|sim| sim[0] - sim[1]}

    diff.each {|val| assert(val.abs < 1e-5)}
  end
=end
end
