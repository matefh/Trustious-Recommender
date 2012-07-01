#!/usr/bin/env ruby

require "./similarity.rb"
include Similarity

module ItemToItem
  
  THRESHOLD = 0.5

  def calculate_similarity(vec1, vec2)
    return Similarity.cosine_rule(vec1, vec2)
  end

  def offline_stage(file_ratings, file_users, file_movies)

    $number_of_users = IO.readlines(file_users).length + 1
    $number_of_movies = IO.readlines(file_movies).length + 1

    $movies_similarity = Array.new($number_of_movies) {{}}
    $rated_movies_per_user = Hash.new()
    $movies_of_user = Hash.new() {[]}
    $users_of_movie = Hash.new() {[]}


    IO.readlines(file_ratings).each{ |line|
      line = line.split("::")
      user_ID = Integer(line[0])
      movie_ID = Integer(line[1])
      rating = Integer(line[2])

      $movies_of_user[user_ID] += [movie_ID]
      $users_of_movie[movie_ID] += [user_ID]
      $rated_movies_per_user[[user_ID, movie_ID]] = rating
    }

    $neighborhood = Array.new($number_of_movies) {[]}

    for movie1 in 1...$number_of_movies
      similar_movies = Array.new(0)
      $users_of_movie[movie1].each{ |user|
	similar_movies = similar_movies | $movies_of_user[user]
      }
      similar_movies = similar_movies - [movie1]
      similar_movies.each{ |movie2|
	vector_movie1 = $users_of_movie[movie1] | $users_of_movie[movie2]
	vector_movie2 = $users_of_movie[movie1] | $users_of_movie[movie2]

	vector_movie1.each_index{ |j|
	  user = vector_movie1[j]
	  if $users_of_movie[movie1].length != 0 and $rated_movies_per_user[[user, movie1]] != nil
	    vector_movie1[j] = $rated_movies_per_user[[user, movie1]].to_f / $users_of_movie[movie1].length.to_f
	  else
	    vector_movie1[j] = 0
	  end
	}

	vector_movie2.each_index{ |j|
	  user = vector_movie2[j]
	  if $users_of_movie[movie2].length != 0 and $rated_movies_per_user[[user, movie2]] != nil
	    vector_movie2[j] = $rated_movies_per_user[[user, movie2]].to_f / $users_of_movie[movie2].length.to_f
	  else
	    vector_movie2[j] = 0
	  end
	}

	similarity = Similarity.cosine_rule(vector_movie1, vector_movie2)
	if similarity.abs > THRESHOLD
	    $neighborhood[movie1] += [movie2]
	    $movies_similarity[movie1][movie2] = similarity
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
  def expected_rating(user, movie)
    rated_movies = $movies_of_user[user].clone
    ratings = rated_movies.map {|m| $rated_movies_per_user[[user, m]]}
    similarities = rated_movies.map {| m| $movies_similarity[movie][m] || 0}
    return Similarity.compute_expected_rating(ratings, similarities)
  end
end
