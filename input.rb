#!/usr/bin/env ruby

require './recommender.rb'
include ItemToItem, UserToUser

module Input

  $itembased_precomputed = false
  $userbased_precomputed = false

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
    File.open("Precomputed_data.txt", "r").each_line{ |line|
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


  def read_ratings(infile)
    lines_of_input = IO.readlines(infile)
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
    File.open("Precomputed_data.txt", "w") do |out|
      for movie1 in 1...$number_of_movies
        $movies_similarity[movie1].each_key{ |movie2|
          out.print sprintf "S %d %d %lf\n", movie1, movie2, $movies_similarity[movie1][movie2]
        }
      end
    end

    $itembased_precomputed = true
  end


  def precompute_userbased(infile)
    UserToUser.offline_stage_userbased(infile)
    File.open("Precomputed_user_data.txt", "w") do |out|
      for user1 in 1...$number_of_users
        $users_similarity[user1].each_key { |user2|
          out.print sprintf "S %d %d %f\n", user1, user2, $users_similarity[user1][user2]
        }
      end
    end

    $userbased_precomputed = true
  end
end
