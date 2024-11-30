extends TextureRect

signal on_submit

@onready var results_label = $VBoxContainer/ResultsLabel
@onready var submit_button = $VBoxContainer/Button
@onready var unlock_panel = $VBoxContainer/UnlockPanel
@onready var unlock_img = $VBoxContainer/UnlockPanel/TextureRect

func _ready() -> void:
	visible = false
	unlock_panel.visible = false

func show_victory(card: UserCard) -> void:
	if card != null:
		unlock_img.texture = Resources.get_card_sprite(card.cat_idx, card.card_idx)
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

func _submit():
	on_submit.emit()
