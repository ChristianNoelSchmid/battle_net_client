extends Object
class_name RiddleGuessResultModel

var correct: RewardModel
var incorrect: bool

func parse_variant(variant):
	if 'incorrect' in variant:
		correct = null
		incorrect = true
	elif 'correct' in variant:
		correct = load("res://models/reward_model.gd").new()
		correct.parse_variant(variant.correct)
		incorrect = false
