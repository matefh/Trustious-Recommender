#!/usr/bin/env ruby

require './linear_algebra.rb'
require './similarity.rb'
require './recommender.rb'
require './statistics.rb'
require './input.rb'
include LinearAlgebra, Similarity, ItemToItem, Statistics, Input, UserToUser


Input.precompute_userbased('trustious_opinions.data')
File.open("table_of_recommendations.txt", "w") do |out|
  for user in 1...$number_of_users
    out.printf "%s:\n", $users_names[user]
    out.puts "\t", UserToUser.online_stage_userbased(user, $number_of_movies).map {|m| "\t" + $movies_names[m]}
  end
end
