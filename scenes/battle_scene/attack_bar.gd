extends Control

@onready var attack_labels = [ $Attack1, $Attack2, $Attack3, $Attack4, ]

func set_enabled(enabled: bool) -> void:
	for button in attack_labels:
		button.disabled = !enabled

func set_power(power: int) -> void:
	for i in len(attack_labels):
		if power <= i:
			attack_labels[i].disabled = true
			attack_labels[i].modulate = Color.RED
		else:
			attack_labels[i].disabled = false
			attack_labels[i].modulate = Color.GREEN

func set_attack_text(text: Array) -> void:
	for i in len(attack_labels):
		attack_labels[i].find_child('VBoxContainer').find_child('Label').text = text[i]
