extends Object
class_name UserCard

var cat_idx: int
var card_idx: int
var confirmed: bool

func parse_variant(variant):
	cat_idx = variant.cat_idx
	card_idx = variant.card_idx
	if "confirmed" in variant:
		confirmed = variant.confirmed
