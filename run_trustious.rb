#!/usr/bin/env ruby

require './linear_algebra.rb'
require './similarity.rb'
require './recommender.rb'
require './statistics.rb'
require './input.rb'
include LinearAlgebra, Similarity, ItemToItem, Statistics, Input, UserToUser


Input.precompute_userbased('trustious_opinions.data')
