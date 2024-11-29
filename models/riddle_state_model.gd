extends Object
class_name RiddleStateModel

var text: String
var answer_len: int

func parse_variant(variant):
    text = variant.text
    answer_len = variant.answer_len