extends TextureRect

@onready var results_label = $VBoxContainer/ResultsLabel
@onready var submit_button = $VBoxContainer/Button
@onready var unlock_panel = $VBoxContainer/UnlockPanel
@onready var unlock_img = $VBoxContainer/UnlockPanel/TextureRect

func _ready() -> void:
	visible = false
	unlock_panel.visible = false

func show_victory(idxs: Array) -> void:
	if idxs != null:
		unlock_img.texture = Resources.get_card_sprite(idxs[0], idxs[1])
		unlock_panel.visible = true
	else:
		unlock_panel.visible = false
	results_label.modulate = Color.WHITE
	results_label.text = "VICTORY!"
	visible = true

func show_defeat() -> void:
	results_label.modulate = Color.DARK_RED
	results_label.text = "DEFEAT!"
	visible = true
