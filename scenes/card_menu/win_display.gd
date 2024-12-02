extends TextureRect

signal on_submit

@onready var animation_player = $AnimationPlayer
@onready var cards = [
	$VBoxContainer/HBoxContainer/Card1,
	$VBoxContainer/HBoxContainer/Card2,
	$VBoxContainer/HBoxContainer/Card3,
]

func display(cat1_tex, cat2_tex, cat3_tex):
	cards[0].texture = cat1_tex
	cards[1].texture = cat2_tex
	cards[2].texture = cat3_tex
	
	animation_player.play("reveal")
	visible = true

func _on_submit_pressed():
	on_submit.emit()
