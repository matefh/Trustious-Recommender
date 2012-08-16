#!/usr/bin/env ruby

require "./normalizers.rb"
include Normalizer

module ItemToItem

  def offline_stage_itembased(infile)

    Input.read_ratings(infile)

    if $itembased_precomputed
    then
      Input.read_precomputed_itembased_data
      for movie1 in 1...$number_of_movies
        $movies_similarity[movie1].each_key{ |movie2|
          similarity = $movies_similarity[movie1][movie2]
          if similarity > $threshold
            $movies_neighborhood[movie1].push(movie2)
          end
        }
      end
    else
      for movie1 in 1...$number_of_movies
        similar_movies = Array.new
        $users_of_movie[movie1].each {|user| similar_movies |= $movies_of_user[user]}
        similar_movies = similar_movies - [movie1]

        similar_movies.each{ |movie2|
          common_users = $users_of_movie[movie1] & $users_of_movie[movie2]
          movie1_ratings = common_users.map {|user| get_rating(user, movie1)}
          movie2_ratings = common_users.map {|user| get_rating(user, movie2)}

         # weights = common_users.map {|user| Math.log($number_of_movies.to_f / $movies_of_user[user].size.to_f)}
          similarity = calculate_similarity(movie1_ratings, movie2_ratings)
          similarity *= [$alpha, common_users.size].min / $alpha.to_f
          if similarity > -EPSILON
            $movies_similarity[movie1][movie2] = similarity
            if similarity.abs > $threshold
              $movies_neighborhood[movie1].push(movie2)
            end
          end
        }
      end
    end
  end


  def online_stage_itembased(user, number_of_needed_recommendations)
    recommended_movies = Array.new
    $movies_of_user[user].each {|movie| recommended_movies |= $movies_neighborhood[movie]}
    recommended_movies -= $movies_neighborhood[user]
    recommended_movies.map {|m| [expected_rating_itembased(user, m), m]}
    recommended_movies.sort {|x,y| y <=> x }
    return recommended_movies[0...number_of_needed_recommendations].map {|m| m[1]}
  end


  def expected_rating_itembased(user, movie)
    rated_movies = $movies_neighborhood[movie].keep_if {|m| not get_rating(user, m).nil?}
    ratings = rated_movies.map {|m| get_rating(user, m)}
    similarities = rated_movies.map {|m| $movies_similarity[movie][m]}

    output_rating = compute_expected_rating(ratings, similarities)
    if $normalizing_rating
    then
      output_rating = denormalize_rating(output_rating, user, movie)
    end
    #output_rating = (output_rating + 0.5).to_i
    return output_rating
  end
end




module UserToUser
  def offline_stage_userbased(infile)

    Input.read_ratings(infile)

    if $userbased_precomputed
    then
      Input.read_precomputed_userbased_data
      for user1 in 1...$number_of_users
        $user_similarity[user1].each_key { |user2|
          similarity = $user_similarity[user1][user2]
          if similarity > $threshold
            $users_neighborhood[user1].push(user2)
          end
        }
      end
    else
      for user1 in 1...$number_of_users
        similar_users = Array.new
        $movies_of_user[user1].each { |movie| similar_users |= $users_of_movie[movie]}

        similar_users -= [user1]
        for user2 in similar_users
          common_movies = $movies_of_user[user1] & $movies_of_user[user2]
          user1_ratings = common_movies.map {|movie| get_rating(user1, movie)}
          user2_ratings = common_movies.map {|movie| get_rating(user2, movie)}

         # weights = common_movies.map {|movie| Math.log($number_of_users.to_f / $users_of_movie[movie].size.to_f)}
          similarity = calculate_similarity(user1_ratings, user2_ratings)
          similarity *= [$alpha, common_movies.size].min / $alpha.to_f
          if similarity > -EPSILON
          then
            $users_similarity[user1][user2] = similarity
            if similarity.abs > $threshold
              $users_neighborhood[user1].push(user2)
            end
          end
        end
      end
    end
  end


  def online_stage_userbased(user, number_of_needed_recommendations)
    recommended_movies = Array.new
    $users_neighborhood[user].each {|v| recommended_movies |= $movies_of_user[v]}
    recommended_movies -= $movies_of_user[user]
    recommended_movies.map {|movie| [expected_rating_userbased(user, movie), movie]}
    recommended_movies.sort {|x,y| y <=> x}
    return recommended_movies[0...number_of_needed_recommendations].map {|x| x[1]}
  end


  def expected_rating_userbased(user, movie)
    similar_users = $users_neighborhood[user].keep_if {|v| not get_rating(v, movie).nil?}
    ratings = similar_users.map {|v| get_rating(v, movie)}
    similarities = similar_users.map {|v| $users_similarity[user][v]}

    output_rating = compute_expected_rating(ratings, similarities)
    if $normalizing_rating
    then
      output_rating = denormalize_rating(output_rating, user, movie)
    end
    #output_rating = (output_rating + 0.5).to_i
    return output_rating
  end
end
