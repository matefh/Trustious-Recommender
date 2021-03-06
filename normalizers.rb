#!/usr/bin/env ruby

require './similarity'
include Similarity

module Normalizer

  $threshold = 0.3
  $alpha = 1
  $item_based_normalization = false
  $normalizing_rating = true

  def set_threshold(x)
    $threshold = x
  end


  def set_normalization(x)
    $normalizing_rating = x
  end


  def set_normalization_type(x)
    $item_based_normalization = x
  end


  def set_alpha(x)
    $alpha = x
  end


  def normalize_rating(rating, user, movie)
    return normalize_rating_z_score(rating, user, movie)
  end


  def denormalize_rating(rating, user, movie)
    return denormalize_rating_z_score(rating, user, movie)
  end


  def normalize_rating_z_score(rating, user, movie)
    if $item_based_normalization
    then
      if $std_dev_item_rating[movie].abs > EPSILON
      then
        return (rating - $average_item_rating[movie]) / $std_dev_item_rating[movie]
      else
        return 0
      end
    else
      if $std_dev_user_rating[user].abs > EPSILON
      then
        return (rating - $average_user_rating[user]) / $std_dev_user_rating[user]
      else
        return 0
      end
    end
  end


  def denormalize_rating_z_score(rating, user, movie)
    if $item_based_normalization
    then
      return $average_item_rating[movie] + $std_dev_item_rating[movie] * rating
    else
      return $average_user_rating[user] + $std_dev_user_rating[user] * rating
    end
  end


  def normalize_rating_mean_centering(rating, user, movie)
    if $item_based_normalization
    then
      return rating - $average_item_rating[movie]
    else
      return rating - $average_user_rating[user]
    end
  end


  def denormalize_rating_mean_centering(rating, user, movie)
    if $item_based_normalization
    then
      return rating + $average_item_rating[movie]
    else
      return rating + $average_user_rating[user]
    end
  end


  def get_rating(user, item)
    if $normalizing_rating
    then
      return $normalized_rating[[user, item]]
    else
      return $rated_movies_per_user[[user, item]]
    end
  end


  def calculate_similarity(vec1, vec2, weight=nil)
    return cosine_rule(vec1, vec2, weight)
  end


  def compute_expected_rating(rating_list, similarity_list)
    weighted_rating = dot_product(rating_list, similarity_list)
    total_similarity = 0
    similarity_list.each {|similarity| total_similarity += similarity.abs}
    if total_similarity.abs > EPSILON
    then
      return weighted_rating.to_f / total_similarity.to_f
    else
      return 0
    end
  end
end
