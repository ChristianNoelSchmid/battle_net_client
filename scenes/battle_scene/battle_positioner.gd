extends Node

@export var player = true

var parent

func _ready() -> void:
	parent = get_parent()
	get_viewport().size_changed.connect(_on_viewport_size_changed)
	_on_viewport_size_changed()

func _on_viewport_size_changed():
	var rect = get_viewport().get_visible_rect()
	parent.scale = Vector2(rect.size.y / 70, rect.size.y / 70)
	parent.global_position.y = rect.size.y / 2.25
	if player:
		parent.global_position.x = rect.size.x / 4
	else:
		parent.global_position.x = rect.size.x - (rect.size.x / 4)
