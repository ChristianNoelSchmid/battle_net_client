extends Object
class_name StatsModel

var health: int
var power: int
var armor: int
var miss_turn: bool

func parse_variant(variant):
    health = variant.health
    power = variant.power
    armor = variant.armor
    miss_turn = variant.miss_turn