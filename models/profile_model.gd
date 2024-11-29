extends Object
class_name ProfileModel

var name: String
var attacks: Array

func parse_variant(variant):
    name = variant.name
    attacks = variant.attacks