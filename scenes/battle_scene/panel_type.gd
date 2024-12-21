extends Panel

@onready var texture = $TextureRect

func set_next(type: int, pow: int):
	if type == 0:   # Attack
		texture.texture = load("res://assets/attack_%d.png" % pow)
	elif type == 1: # Defend
		texture.texture = load("res://assets/defend.png")
	else:  # Idle
		texture.texture = load("res://assets/idle.png")

func clear():
	texture.texture = null
