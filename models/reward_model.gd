extends Object
class_name RewardModel

var item_idxs: Array
var card: UserCard

func parse_variant(variant):
	item_idxs = variant.item_idxs
	if variant.card != null:
		card = load("res://models/user_card_model.gd").new()
		card.parse_variant(variant.card)
