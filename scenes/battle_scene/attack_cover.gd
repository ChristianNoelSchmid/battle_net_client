extends Panel

@onready var label = $HBoxContainer/Label
@onready var tex = $HBoxContainer/TextureRect

var attack_texs = [
	load("res://assets/attack_1.png"),
	load("res://assets/attack_2.png"),
	load("res://assets/attack_3.png"),
	load("res://assets/attack_4.png"),
]

var defend_tex = load("res://assets/defend.png")

func show_attacking(power):
	label.text = "ATTACKING"
	tex.texture = attack_texs[power - 1]
	visible = true
	
func show_defending():
	label.text = "DEFENDING"
	tex.texture = defend_tex
	visible = true
