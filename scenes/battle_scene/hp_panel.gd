extends Control

@onready var label_hp = $"HP Panel/HP"
@onready var sub_health = $Sub

# Whether the first battle message has been received from the server
var recvd_first_msg = false

# The entity's current health
var current_health = 0

func set_health(health):
	label_hp.text = "❤️ %s" % health

	if recvd_first_msg:
		var dmg_dealt = current_health - health
		if dmg_dealt > 0: sub_health.show_hit(dmg_dealt)	

	recvd_first_msg = true
	current_health = health
