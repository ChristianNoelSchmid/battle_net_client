extends Node

@export var animation_group = 'player'
@onready var player: AnimationPlayer = get_parent().find_child("AnimationPlayer")

func attack(power):
	if power <= 2:
		player.play("%s/attack_light" % animation_group)
	else:
		player.play("%s/attack_hard" % animation_group)

func defeat():
	player.play("%s/defeat" % animation_group)

func hit():
	player.play("%s/hit" % animation_group)
