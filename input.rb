#!/usr/bin/env ruby

require './linear_algebra.rb'
require './similarity.rb'
require './recommender.rb'
require './statistics.rb'
require 'test/unit'
include LinearAlgebra, Similarity, ItemToItem, Statistics

module Input
  def init(n, m)
    $average_user_rating = Array.new(n) {0}
    $average_item_rating = Array.new(m) {0}
    $std_dev_user_rating = Array.new(n) {0}
    $std_dev_item_rating = Array.new(m) {0}
    $movies_similarity = Array.new(m) {{}}
    $rated_movies_per_user = Hash.new(n)
    $normalized_rating = Hash.new()
    $movies_of_user = Hash.new() {[]}
    $users_of_movie = Hash.new() {[]}
    $neighborhood = Array.new(m) {[]}
  end

  def read_ratings(infile)
    lines_of_input = IO.readlines(infile)
    $number_of_users = lines_of_input[0].split(" ")[0].to_i + 1
    $number_of_movies = lines_of_input[0].split(" ")[1].to_i + 1
    init($number_of_users, $number_of_movies)

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
  end

  def precompute(infile)
    ItemToItem.offline_stage(infile)
    File.open("Precomputed_data.txt", "w") do |out|
      out.print $number_of_users, " ", $number_of_movies, "\n"
      $rated_movies_per_user.each_key{ |key|
        out.print "R ", key[0], " ", key[1], " ", $rated_movies_per_user[key], "\n"
      }
      for movie in 1...$number_of_movies
        $movies_similarity[movie].each_key{ |key|
          out.print "S ", movie, " ", key, " ", $movies_similarity[movie][key], "\n"
        }
      end
      for movie in 1...$number_of_movies
        out.print "N ", movie, " ", $neighborhood[movie].size
        $neighborhood[movie].each{ |neighbor|
          out.print " ", neighbor
        }
        out.print "\n"
      end
    end
  end

end
