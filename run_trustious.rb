#!/usr/bin/env ruby

require './linear_algebra.rb'
require './similarity.rb'
require './recommender.rb'
require './statistics.rb'
require './input.rb'
require 'test/unit'
include LinearAlgebra, Similarity, ItemToItem, Statistics, Input, UserToUser


Input.precompute_userbased('trustious_opinions.data')
