extends Object
class_name RiddleStateModel

var text: String
var ans_scramb: String

func parse_variant(variant):
	text = variant.text
	ans_scramb = variant.ans_scramb
