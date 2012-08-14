#!/usr/bin/env ruby

require "./normalizers.rb"
include Normalizer

module ItemToItem

  EPSILON = 1e-9
  DEBUG = false
  def offline_stage_itembased(infile)

    Input.read_ratings(infile)

    if $itembased_precomputed
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
        $users_of_movie[movie1].each{ |user|
          similar_movies = similar_movies | $movies_of_user[user]
        }
        movie1_user_count = $users_of_movie[movie1].size.to_f
        similar_movies = similar_movies - [movie1]

        similar_movies.each{ |movie2|
          common_users = $users_of_movie[movie1] & $users_of_movie[movie2]
          vector_movie1 = common_users.clone
          vector_movie2 = common_users.clone
          movie2_user_count = $users_of_movie[movie2].size.to_f


          vector_movie1.each_index{ |j|
            user = vector_movie1[j]
            value = get_rating(user, movie1)
            if not value.nil?
              vector_movie1[j] = value.to_f / movie1_user_count
            else
              vector_movie1[j] = nil
            end
          }

          vector_movie2.each_index{ |j|
            user = vector_movie2[j]
            value = get_rating(user, movie2)
            if not value.nil?
              vector_movie2[j] = value.to_f / movie2_user_count
            else
              vector_movie2[j] = nil
            end
          }

         # weights = users.map {|u| Math.log($number_of_movies.to_f / $movies_of_user[u].size.to_f)}
          similarity = calculate_similarity(vector_movie1, vector_movie2)
          if similarity > -EPSILON
            $movies_similarity[movie1][movie2] = similarity
            if similarity.abs > $threshold
              $movies_neighborhood[movie1].push(movie2)
            end
          end
        }
      end
    end
    if DEBUG
    then
      File.open("ratings.txt", "w") do |out|
        for movie1 in 1...$number_of_movies
          for movie2 in 1...$number_of_movies
            if not $movies_neighborhood[user1][user2].nil? and $movies_neighborhood[user1][user2] > 0.99
            then
              common_users = $users_of_movie[movie1] | $movies_of_user[movie2]
              rate1 = common_users.map {|movie| get_rating(user, movie1)}
              rate2 = common_users.map {|movie| get_rating(user, movie2)}
              com = ($users_of_movie[movie1] & $users_of_movie[movie2]).size
              out.printf "sim(%d, %d) = %f, %d are common\n%d %s\n%d %s\n\n", movie1, movie2, $movies_neighborhood[movie1][movie2], com, movie1, rate1, movie2, rate2
            end
          end
        end
      end
    end

  end

  def getting_list_of_ratings_itembased(user, number_of_needed_recommendations)
    potentialy_recommended_movies = Array.new
    $movies_of_user[user].each{ |movie|
      potentialy_recommended_movies |= $movies_neighborhood[movie]
    }
    potentialy_recommended_movies -= $movies_of_user[user]

    return potentialy_recommended_movies.map {|m| [expected_rating_itembased(user, m), m]}
  end


  def online_stage_itembased(user, number_of_needed_recommendations)
    recommended_movies = getting_list_of_ratings_itembased(user, number_of_needed_recommendations)
    recommended_movies.sort {|x,y| y <=> x }
    return recommended_movies[0...number_of_needed_recommendations].map {|m| m[1]}
  end


  def expected_rating_itembased(user, movie)
    rated_movies = $movies_neighborhood[movie].keep_if {|m| not get_rating(user, m).nil?}
    ratings = rated_movies.map {|m| get_rating(user, m)}
    similarities = rated_movies.map {|m| $movies_similarity[movie][m]}
    #weights = rated_movies.map {|m| Math.log($number_of_users.to_f / $users_of_movie[m].size.to_f)}

    output_rating = Similarity.compute_expected_rating(ratings, similarities)
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
        $movies_of_user[user1].each { |movie|
          similar_users |= $users_of_movie[movie]
        }
        movies_of_user1 = $movies_of_user[user1].size.to_f

        similar_users -= [user1]
        for user2 in similar_users
          common_movies = $movies_of_user[user1] & $movies_of_user[user2]
          user1_ratings = common_movies.clone
          user2_ratings = common_movies.clone

          movies_of_user2 = $movies_of_user[user2].size.to_f

          user1_ratings.each_index { |j|
            movie = user1_ratings[j]
            rating = get_rating(user1, movie)
            if not rating.nil?
            then
              user1_ratings[j] = rating / movies_of_user1
            else
              user1_ratings[j] = nil
            end
          }

          user2_ratings.each_index { |j|
            movie = user2_ratings[j]
            rating = get_rating(user2, movie)
            if not rating.nil?
            then
              user2_ratings[j] = rating / movies_of_user2
            else
              user2_ratings[j] = nil
            end
          }


          similarity = calculate_similarity(user1_ratings, user2_ratings)
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
    if DEBUG
    then
      File.open("ratings.txt", "w") do |out|
        for user1 in 1...$number_of_users
          for user2 in 1...$number_of_users
            if not $users_similarity[user1][user2].nil? and $users_similarity[user1][user2] > 0.99
            then
              common_movies = $movies_of_user[user1] | $movies_of_user[user2]
              rate1 = common_movies.map {|movie| get_rating(user1, movie)}
              rate2 = common_movies.map {|movie| get_rating(user2, movie)}
              com = ($movies_of_user[user1] & $movies_of_user[user2]).size
              out.printf "sim(%d, %d) = %f, %d are common\n%d %s\n%d %s\n\n", user1, user2, $users_similarity[user1][user2], com, user1, rate1, user2, rate2
            end
          end
        end
      end
    end

  end

  def getting_list_of_ratings_userbased(user, number_of_needed_recommendations)
    potentialy_recommended_movies = Array.new
    $users_neighborhood[user].each { |v|
      potentialy_recommended_movies |= $movies_of_user[v]
    }
    potentialy_recommended_movies -= $movies_of_user[user]

    return potentialy_recommended_movies.map {|movie| [expected_rating_userbased(user, movie), movie]}
  end


  def online_stage_userbased(user, number_of_needed_recommendations)
    recommended_movies = getting_list_of_ratings_userbased(user, number_of_needed_recommendations)
    recommended_movies.sort {|x,y| y <=> x}
    return recommended_movies[0...number_of_needed_recommendations].map {|x| x[1]}
  end


  def expected_rating_userbased(user, movie)
    similar_users = $users_neighborhood[user].keep_if {|v| not get_rating(v, movie).nil?}
    ratings = similar_users.map {|v| get_rating(v, movie)}
    similarities = similar_users.map {|v| $users_similarity[user][v]}

    output_rating = Similarity.compute_expected_rating(ratings, similarities)
    if $normalizing_rating
    then
      output_rating = denormalize_rating(output_rating, user, movie)
    end
    #output_rating = (output_rating + 0.5).to_i
    return output_rating
  end
end
