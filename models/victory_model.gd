extends Object
class_name VictoryModel

var reward: RewardModel
var pl_dmg_dealt: int

func parse_variant(variant):
	reward = load("res://models/reward_model.gd").new()
	reward.parse_variant(variant.reward)
	pl_dmg_dealt = variant.pl_dmg_dealt
