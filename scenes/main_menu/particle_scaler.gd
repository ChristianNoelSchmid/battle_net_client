extends CPUParticles2D

var orig_scale = 0
var screen_dpi = 0
var standard_dpi = 140

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	orig_scale = scale_amount_min
	screen_dpi = DisplayServer.screen_get_dpi()
	
	get_viewport().size_changed.connect(_update_scale)
	_update_scale()
	
func _update_scale():
	scale_amount_min = orig_scale * (screen_dpi / standard_dpi)
