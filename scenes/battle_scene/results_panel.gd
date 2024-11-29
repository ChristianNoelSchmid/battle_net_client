extends Panel

@onready var results_label = $"Results Label"
@onready var submit_button: Button = $Button
@onready var unlock_panel = $"Unlock Panel"

func _ready() -> void:
	visible = false
	unlock_panel.visible = false

func show_victory() -> void:
	results_label.modulate = Color.WHITE
	results_label.text = "VICTORY!"
	visible = true

func show_defeat() -> void:
	results_label.modulate = Color.DARK_RED
	results_label.text = "DEFEAT!"
	visible = true