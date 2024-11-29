extends Object
class_name DefeatModel

var monst_dmg: int
var consq: ConsequenceModel
var pl_dmg_dealt: int

func parse_variant(variant):
    monst_dmg = variant.monst_dmg
    pl_dmg_dealt = variant.pl_dmg_dealt
    consq = load("res://models/consequence_model.gd").new()
    consq.parse_variant(variant.consq)
    pl_dmg_dealt = variant.pl_dmg_dealt