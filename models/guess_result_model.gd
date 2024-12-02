extends Object
class_name GuessResult

var correct: Array
var incorrect: bool

func parse_variant(variant):
	if type_string(typeof(variant)) == "String":
		correct = []
		incorrect = true
	elif 'correct' in variant:
		correct = variant.correct
		incorrect = false
