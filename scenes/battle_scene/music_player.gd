extends AudioStreamPlayer2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if get_playback_position() >= 66.02:
		play(24.05)
