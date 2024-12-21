extends AudioStreamPlayer2D

@onready var song = load("res://assets/lm.mp3")

func _ready() -> void:
	stream = song
