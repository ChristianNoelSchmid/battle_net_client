extends Panel
class_name QuestTypePanel

var _label_no_quest: Label
var _button_battle: Button
var _button_riddle: Button
var _v_box_buttons: Control

func _ready():
	_label_no_quest = find_child("LabelNoQuest", true)
	_button_battle = find_child("ButtonBattle", true)
	_button_riddle = find_child("ButtonRiddle", true)
	_v_box_buttons = find_child("VBoxButtons", true)

func set_available_quests(battle: bool, riddle: bool):
	_button_battle.visible = battle
	_button_riddle.visible = riddle

	if(!_button_battle.visible && !_button_riddle.visible):
		_v_box_buttons.visible = false
		_label_no_quest.visible = true
	else:
		_v_box_buttons.visible = true
		_label_no_quest.visible = false
