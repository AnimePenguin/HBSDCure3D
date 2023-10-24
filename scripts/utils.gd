class_name Util

static func sum(nums: Array[int]) -> int:
	return nums.reduce(func(acc, num): return acc + num)

static func weighted_rand(values: Array, weights: Array[int]):
	var total_weights := sum(weights)
	
	var rand_num := randi() % total_weights
	
	for i in range(len(values)):
		if rand_num < weights[i]:
			return values[i]
		
		rand_num -= weights[i]
