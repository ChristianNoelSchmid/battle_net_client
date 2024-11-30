extends Object
class_name NextModel

var pl_dmg_dealt: int
var monst_dmg_dealt: int
var monst_pow_used: int

var pl_stats: StatsModel
var monst_stats: StatsModel
var next_action: ActionModel

func parse_variant(variant):
	pl_dmg_dealt = variant.pl_dmg_dealt
	monst_dmg_dealt = variant.monst_dmg_dealt
	monst_pow_used = variant.monst_pow_used

	pl_stats = load("res://models/stats_model.gd").new()
	pl_stats.parse_variant(variant.pl_stats)
	monst_stats = load("res://models/stats_model.gd").new()
	monst_stats.parse_variant(variant.monst_stats)
	next_action = load("res://models/action_model.gd").new()
	next_action.parse_variant(variant.next_action)
