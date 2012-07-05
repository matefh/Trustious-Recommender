#!/usr/bin/env ruby

require "./similarity.rb"
include Similarity

module ItemToItem

  THRESHOLD = 0.0001

  def calculate_similarity(vec1, vec2)
    return Similarity.cosine_rule(vec1, vec2)
  end

  def offline_stage(file_ratings, file_info, bad_lines)

    $number_of_users = IO.readlines(file_info)[0].to_i + 1
    $number_of_movies = IO.readlines(file_info)[1].to_i + 1

    $movies_similarity = Array.new($number_of_movies) {{}}
    $rated_movies_per_user = Hash.new()
    $movies_of_user = Hash.new() {[]}
    $users_of_movie = Hash.new() {[]}

    bad_lines_index = 0
    bad_lines = bad_lines.sort()

    input_loop_variable = 0
    input = IO.readlines(file_ratings)
    input.each_index{ |line_index|
      line = input[line_index]
      if line_index != bad_lines[bad_lines_index]
  line = line.split(" ")
  user_ID = Integer(line[0])
  movie_ID = Integer(line[1])
  rating = Integer(line[2])
  $movies_of_user[user_ID] += [movie_ID]
  $users_of_movie[movie_ID] += [user_ID]
  $rated_movies_per_user[[user_ID, movie_ID]] = rating
      end
      if line_index == bad_lines[bad_lines_index]
  bad_lines_index += 1
      end
      input_loop_variable += 1
    }

    $neighborhood = Array.new($number_of_movies) {[]}

    for movie1 in 1...$number_of_movies
      similar_movies = Array.new(0)
      $users_of_movie[movie1].each{ |user|
  similar_movies = similar_movies | $movies_of_user[user]
      }
      movie1_user_count = $users_of_movie[movie1].length.to_f
      similar_movies = similar_movies - [movie1]

      similar_movies.each{ |movie2|
  vector_movie1 = $users_of_movie[movie1] | $users_of_movie[movie2]
  vector_movie2 = vector_movie1.clone
  movie2_user_count = $users_of_movie[movie2].length.to_f

  vector_movie1.each_index{ |j|
    user = vector_movie1[j]
    value = $rated_movies_per_user[[user, movie1]].to_f
    if value != nil
      vector_movie1[j] = value / movie1_user_count
    else
      vector_movie1[j] = nil
    end
  }

  vector_movie2.each_index{ |j|
    user = vector_movie2[j]
    value = $rated_movies_per_user[[user, movie2]].to_f
    if value != nil
      vector_movie2[j] = value / movie2_user_count
    else
      vector_movie2[j] = nil
    end
  }

  no_nils = vector_movie1.zip(vector_movie2).keep_if {|x|  !(x[0].nil? or x[1].nil?)}
  vector_movie1 = no_nils.map {|x| x[0]}
  vector_movie2 = no_nils.map {|x| x[1]}
  similarity = Similarity.cosine_rule(vector_movie1, vector_movie2)
  $movies_similarity[movie1][movie2] = similarity
  if similarity.abs > THRESHOLD
      $neighborhood[movie1].push(movie2)
  end
      }
    end
  end

  def getting_list_of_ratings(user, number_of_needed_recommendations)
    potentialy_recommended_movies = []
    $movies_of_user[user].each{ |movie|
      potentialy_recommended_movies |= $neighborhood[movie]
    }
    potentialy_recommended_movies -= $movies_of_user[user]

    return potentialy_recommended_movies.map {|m| [expected_rating(user, m), m]}
  end

  def online_stage(user, number_of_needed_recommendations)
    recommended_movies = getting_list_of_ratings(user, number_of_needed_recommendations)
    recommended_movies.sort {|x,y| y <=> x }
    return recommended_movies[0...number_of_needed_recommendations].map {|m| m[1]}
  end

  def expected_rating(user, movie)
    rated_movies = $movies_of_user[user].clone
    ratings = rated_movies.map {|m| $rated_movies_per_user[[user, m]]}
    similarities = rated_movies.map {| m| $movies_similarity[movie][m] || 0}
    return Similarity.compute_expected_rating(ratings, similarities)
    #output_rating = (output_rating + 0.5).to_i
    return output_rating
  end
end
