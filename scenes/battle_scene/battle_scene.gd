extends Node 

var ws: WebSocketPeer
@onready var attack_heading: Label = $UI/Panel/AttackHeading
@onready var player_sprite: Sprite2D = $PlayerSprite
@onready var enemy_sprite: Sprite2D = $EnemySprite

@onready var power_bar = $UI/Control/Attack
@onready var pl_health_bar = $"UI/Player HP"
@onready var monst_health_bar = $"UI/Monster HP"
@onready var results_panel = $"UI/Results Panel"

func _ready():
	# Connect to the server via WebSocket
	ws = WebSocketPeer.new()
	var err = ws.connect_to_url("ws://127.0.0.1:3005/battle")
	if err != OK:
		print(err)

	player_sprite.texture = Resources.get_player_sprite(GameState.state.user_id)
	enemy_sprite.texture = Resources.get_enemy_sprite(QuestState.state.monster_state.res_idx)

	var profile = Profiles.get_profile(GameState.state.user_id)
	power_bar.set_attack_text(profile.attacks)


func _process(_delta):
	ws.poll()

	while ws.get_available_packet_count():
		var msg = ws.get_packet().get_string_from_utf8()
		if msg == "Auth?":
			print("Sending access token")
			ws.send_text(Auth.access_token)
		else:
			print("Received data: ", msg)
			var json = JSON.parse_string(msg)
			var res = load("res://models/battle_result_model.gd").new()
			res.parse_variant(json)

			if res.next:
				power_bar.set_power(res.next.pl_stats.power)
				attack_heading.text = res.next.next_action.flv_text
				pl_health_bar.set_health(res.next.pl_stats.health)
				monst_health_bar.set_health(res.next.monst_stats.health)

			elif res.victory:
				ws.close()
				QuestState.clear_current()
				results_panel.show_victory([res.victory.reward.card.cat_idx, res.victory.reward.card.card_idx])

			elif res.defeat:
				ws.close()
				QuestState.clear_current()
				results_panel.show_defeat()

	var state = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		return
	if state == WebSocketPeer.STATE_CLOSING or state == WebSocketPeer.STATE_CLOSED:
		return

func on_send_message(text: String):
	ws.send_text(text)

func _on_results_button_pressed():
	QuestState.clear_current()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
