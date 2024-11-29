extends Control

@onready var attack_labels = [ $Attack1, $Attack2, $Attack3, $Attack4, ]

func set_power(power: int) -> void:
	for i in len(attack_labels):
		attack_labels[i].disabled = (power <= i)

func set_attack_text(text: Array) -> void:
	for i in len(attack_labels):
		attack_labels[i].text = text[i]
