extends Object
class_name BattleResultModel

var next: NextModel
var victory: VictoryModel
var defeat: DefeatModel

func parse_variant(variant):
	if "next" in variant:
		next = load("res://models/next_model.gd").new()
		next.parse_variant(variant.next)
	if "victory" in variant:
		victory = load("res://models/victory_model.gd").new()
		victory.parse_variant(variant.victory)
	if "defeat" in variant:
		defeat = load("res://models/defeat_model.gd").new()
		defeat.parse_variant(variant.defeat)
