#!/usr/bin/env ruby

require './recommender.rb'
include ItemToItem, UserToUser

module Input

  $itembased_precomputed = false
  $userbased_precomputed = false
  Hashed_Data = false
  DEBUG = false

  def set_itembased_precomputed(x)
    $itembased_precomputed = x
  end


  def set_userbased_precomputed(x)
    $userbased_precomputed = x
  end


  def init
    $average_user_rating = Array.new($number_of_users) {0}
    $average_item_rating = Array.new($number_of_movies) {0}
    $std_dev_user_rating = Array.new($number_of_users) {0}
    $std_dev_item_rating = Array.new($number_of_movies) {0}
    $rated_movies_per_user = Hash.new($number_of_users)
    $normalized_rating = Hash.new()
    $movies_of_user = Hash.new() {[]}
    $users_of_movie = Hash.new() {[]}
    $movies_similarity = Array.new($number_of_movies) {{}}
    $movies_neighborhood = Array.new($number_of_movies) {[]}
    $users_similarity = Array.new($number_of_users) {{}}
    $users_neighborhood = Array.new($number_of_users) {[]}
  end


  def read_precomputed_itembased_data
    File.open("Precomputed_item_data.txt", "r").each_line{ |line|
      parse = line.split(" ")
      if parse[0] == 'S'
        movie1 = parse[1].to_i
        movie2 = parse[2].to_i
        $movies_similarity[movie1][movie2] = parse[3].to_f
      end
    }
  end


  def read_precomputed_userbased_data
    File.open("Precomputed_user_data.txt", "r").each_line{ |line|
      parse = line.split(" ")
      if parse[0] == 'S'
        user1 = parse[1].to_i
        user2 = parse[2].to_i
        $users_similarity[user1][user2] = parse[3].to_f
      end
    }
  end


  def read_ratings(infile, users_names = "users.data", movies_names = "movies.data")
    lines_of_input = IO.readlines(infile)
    if Hashed_Data
    then
      $users_hash = Hash.new
      $movies_hash = Hash.new
      lines_of_input.each_index { |ind|
        if ind > 0
          line_data = lines_of_input[ind].split(" ")
          user, movie, rating = lines_of_input[ind].split(" ")
          if not $users_hash.keys.include? user
            $users_hash[user] = $users_hash.size + 1
          end
          if not $movies_hash.keys.include? movie
            $movies_hash[movie] = $movies_hash.size + 1
          end
          lines_of_input[ind] = sprintf "%s %s %d\n", $users_hash[user], $movies_hash[movie], rating
        end
      }
      $users_names = Hash.new
      $movies_names = Hash.new
      IO.readlines(users_names).each { |line|
        hash, name = line.split(" ")
        id = $users_hash[hash]
        $users_names[id] = name
      }
      IO.readlines(movies_names).each { |line|
        hash, name = line.split(" ")
        id = $movies_hash[hash]
        $movies_names[id] = name
      }
    end

    $number_of_users = lines_of_input[0].split(" ")[0].to_i + 1
    $number_of_movies = lines_of_input[0].split(" ")[1].to_i + 1
    init

    lines_of_input.each_index{ |line_index|
      if line_index > 0
        line = lines_of_input[line_index].split(" ")
        user_ID = Integer(line[0])
        movie_ID = Integer(line[1])
        rating = Integer(line[2])
        $movies_of_user[user_ID] += [movie_ID]
        $users_of_movie[movie_ID] += [user_ID]
        $rated_movies_per_user[[user_ID, movie_ID]] = rating
        $average_item_rating[movie_ID] += rating
        $average_user_rating[user_ID] += rating
        $std_dev_item_rating[movie_ID] += rating * rating
        $std_dev_user_rating[user_ID] += rating * rating
      end
    }

    for i in 1...$number_of_movies
      if !$users_of_movie[i].nil?
        size = $users_of_movie[i].size
        if size > 0
          $average_item_rating[i] /= size.to_f
          $std_dev_item_rating[i] /= size.to_f
          $std_dev_item_rating[i] -= $average_item_rating[i] * $average_item_rating[i]
          $std_dev_item_rating[i] = Math.sqrt($std_dev_item_rating[i])
        end
      end
    end
    for i in 1...$number_of_users
      if !$movies_of_user[i].nil?
        size = $movies_of_user[i].size
        if size > 0
          $average_user_rating[i] /= size.to_f
          $std_dev_user_rating[i] /= size.to_f
          $std_dev_user_rating[i] -= $average_user_rating[i] * $average_user_rating[i]
          $std_dev_user_rating[i] = Math.sqrt($std_dev_user_rating[i])
        end
      end
    end

    $rated_movies_per_user.each {|key, value|
      user = key[0]
      movie = key[1]
      $normalized_rating[[user, movie]] = normalize_rating($rated_movies_per_user[[user, movie]], user, movie)
    }
  end


  def precompute_itembased(infile)
    ItemToItem.offline_stage_itembased(infile)
    File.open("Precomputed_item_data.txt", "w") do |out|
      for movie1 in 1...$number_of_movies
        $movies_similarity[movie1].each_key{ |movie2|
          if Hashed_Data
          then
            out.printf "S %s %s %f\n", $movies_names[movie1], $movies_names[movie2], $movies_similarity[movie1][movie2]
          else
            out.printf "S %d %d %f\n", movie1, movie2, $movies_similarity[movie1][movie2]
          end
        }
      end
    end

    $itembased_precomputed = true
    if DEBUG
    then
      File.open("debug_similar_items.txt", "w") do |out|
        for movie1 in 1...$number_of_movies
          $movies_similarity[movie1].each_key { |movie2|
            if $movies_similarity[movie1][movie2] > 0.99
            then
              common_users = $users_of_movie[movie1] | $movies_of_user[movie2]
              rate1 = common_users.map {|user| get_rating(user, movie1)}
              rate2 = common_users.map {|user| get_rating(user, movie2)}
              com = ($users_of_movie[movie1] & $users_of_movie[movie2]).size
              out.printf "sim(%d, %d) = %f, %d are common\n%d %s\n%d %s\n\n", movie1, movie2, $movies_similarity[movie1][movie2], com, movie1, rate1, movie2, rate2
            end
          }
        end
      end
    end
  end


  def precompute_userbased(infile)
    UserToUser.offline_stage_userbased(infile)
    File.open("Precomputed_user_data.txt", "w") do |out|
      for user1 in 1...$number_of_users
        $users_similarity[user1].each_key { |user2|
          if Hashed_Data
          then
            out.printf "S %s %s %f\n", $users_names[user1], $users_names[user2], $users_similarity[user1][user2]
          else
            out.printf "S %d %d %f\n", user1, user2, $users_similarity[user1][user2]
          end
        }
      end
    end

    $userbased_precomputed = true
    if DEBUG
    then
      File.open("debug_similar_users.txt", "w") do |out|
        for user1 in 1...$number_of_users
          $users_similarity[user1].each_key { |user2|
            if $users_similarity[user1][user2] > 0.99
            then
              common_movies = $movies_of_user[user1] | $movies_of_user[user2]
              rate1 = common_movies.map {|movie| get_rating(user1, movie)}
              rate2 = common_movies.map {|movie| get_rating(user2, movie)}
              com = ($movies_of_user[user1] & $movies_of_user[user2]).size
              out.printf "sim(%d, %d) = %f, %d are common\n%d %s\n%d %s\n\n", user1, user2, $users_similarity[user1][user2], com, user1, rate1, user2, rate2
            end
          }
        end
      end
    end
  end
end
