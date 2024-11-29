extends Object
class_name MonsterStateModel

var res_idx: int
var stats: StatsModel

func parse_variant(variant):
    res_idx = variant.res_idx
    stats = load("res://models/stats_model.gd").new()
    stats.parse_variant(variant.stats)