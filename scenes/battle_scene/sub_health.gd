extends Label

@export var seconds_to_fade = 1.0
@export var flutter_speed = 2
@export var flutter_dist = 10;

var time = 0
var last_flutter = 0
var last_shown = 0

func show_hit(val: int):
	self_modulate.a = 1.0
	text = "- %d" % val
	last_shown = time

func _process(delta: float):
	time += delta
	if time - last_flutter > (1.0 / flutter_speed):
		self.offset_left = randf() * (flutter_dist * 2) - flutter_dist
		self.offset_top = randf() * (flutter_dist * 2) - flutter_dist
		last_flutter = time
	if time - last_shown > seconds_to_fade:
		self_modulate.a = 0.0
