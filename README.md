Trustious-Recommender
=====================

Recommendation System for Trustious

60,000 ratings were used and 2000 ratings were expected.


Cosine rule similarity: 
Error with rounding = 1.0373041983911953, 
Error without rounding = 1.0007667220147105, 
Number of ratings of absolute difference [0, 1, 2, 3, 4, 5] [770, 976, 222, 32, 0, 0],
Finished in 3693.176052 seconds.



Pearson's correlation simialrity: 
Error with rounding = 1.0793516572461452, 
Error without rounding = 1.037307066916652, 
Number of ratings of absolute difference [0, 1, 2, 3, 4, 5] [741, 997, 205, 57, 0, 0], 
Finished in 3772.552838 seconds.



Euclidean's Distance: 
Error with rounding = 1.105667219374799, 
Error without rounding = 1.0675683922386796, 
Number of ratings of absolute difference [0, 1, 2, 3, 4, 5] [700, 990, 267, 43, 0, 0], 
Finished in 3136.659491 seconds.



Dot product normalized with Euclidean distance: 
Error with rounding = 1.0871982339941506, 
Error without rounding = 1.0512248499598658, 
Number of ratings of absolute difference [0, 1, 2, 3, 4, 5] [722, 990, 245, 42, 1, 0], 
Finished in 3770.770888 seconds.


Item-based rating normalization using Z-Score normalization:
Error with rounding = 0.7286974680894672,
Error without rounding = 0.66288539198081,
Number of ratings of absolute difference [0, 1, 2, 3, 4, 5] [1135, 805, 58, 1, 1, 0],
Finished in 3761.289317 seconds.


Item-based rating normalization using Mean Centering normalization:
Error with rounding = 0.7304108432930059,
Error without rounding = 0.6667065203942877,
Number of ratings of absolute difference [0, 1, 2, 3, 4, 5] [1130, 810, 58, 1, 1, 0],
Finished in 3726.635309 seconds.


User-based rating normalization using Z-Score normalization:
Error with rounding = 0.7304108432930059,
Error without rounding = 0.6695138410800626,
Number of ratings of absolute difference [0, 1, 2, 3, 4, 5] [1150, 781, 67, 2, 0, 0],
Finished in 3618.251631 seconds.


User-based rating normalization using Mean Centering normalization:
Error with rounding = 0.7358668357794091,
Error without rounding = 0.6729826121518161,
Number of ratings of absolute difference [0, 1, 2, 3, 4, 5] [1133, 800, 64, 3, 0, 0],
Finished in 3627.349486 seconds.


User-based rating normalization using Z-Score normalization, Threshold = 0.001, 0.01, 0.1, 0.2, 0.3:
Error with rounding = 0.7304108432930059:
Error without rounding = 0.6695138410800626:
Number of ratings of absolute difference [0, 1, 2, 3, 4, 5] [1150, 781, 67, 2, 0, 0]



14 tests, 60 assertions, 0 failures, 0 errors, 0 skips
