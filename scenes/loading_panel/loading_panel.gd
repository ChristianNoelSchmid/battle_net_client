extends Control

var _spinner: TextureRect

# Called when the node enters the scene tree for the first time.
func _ready():
	_spinner = get_node("Spinner")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	_spinner.rotation_degrees += 360 * delta;
