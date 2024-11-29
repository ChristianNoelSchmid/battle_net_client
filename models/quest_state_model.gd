extends Object
class_name QuestStateModel

var quest_type: int
var monster_state: MonsterStateModel
var riddle_state: RiddleStateModel

func parse_variant(variant):
    quest_type = variant.quest_type
    if variant.monster_state:
        monster_state = load("res://models/monster_state_model.gd").new()
        monster_state.parse_variant(variant.monster_state)
    if variant.riddle_state:
        riddle_state = load("res://models/riddle_state_model.gd").new()
        riddle_state.parse_variant(variant.riddle_state)