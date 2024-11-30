extends Node 

var ws: WebSocketPeer
@onready var attack_heading: Label = $UI/Panel/AttackHeading

@onready var player_sprite: Sprite2D = $Player/Sprite
@onready var enemy_sprite: Sprite2D = $Enemy/Sprite
@onready var player_animator = $Player/Animator
@onready var enemy_animator = $Enemy/Animator

@onready var power_bar = $UI/Control/Attack
@onready var action_cover = $UI/Control/ActionCover
@onready var defend_button: Button = $UI/Control/Defend
@onready var pl_health_bar = $"UI/Player HP"
@onready var monst_health_bar = $"UI/Monster HP"
@onready var results_panel = $UI/ResultsPanel

@onready var music_player = $MusicPlayer

var bat_status: BattleResultModel
var enemy_attack_ts: float = 0.0
var initial = true

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
			bat_status = load("res://models/battle_result_model.gd").new()
			bat_status.parse_variant(json)
			
			if bat_status.next:
				power_bar.set_power(bat_status.next.pl_stats.power)
				monst_health_bar.set_health(bat_status.next.monst_stats.health)

				if initial:
					pl_health_bar.set_health(bat_status.next.pl_stats.health)
					attack_heading.text = bat_status.next.next_action.flv_text
				elif bat_status.next.pl_dmg_dealt > 0:
					enemy_animator.hit()

			elif bat_status.victory:
				enemy_animator.defeat()
				monst_health_bar.subtract_health(bat_status.victory.pl_dmg_dealt)
				attack_heading.visible = false
				ws.close()
				QuestState.clear_current()

				results_panel.show_victory(bat_status.victory.reward.card)
				music_player.stop()
				
			# If it is not victory, enemy has acted
			# Update enemy action a second later
			if bat_status.victory == null && !initial:
				enemy_attack_ts = Time.get_ticks_msec() + 1000
				
			initial = false

	if enemy_attack_ts < Time.get_ticks_msec() && enemy_attack_ts != 0:
		enemy_attack_ts = 0
		if bat_status.next:
			if bat_status.next.monst_pow_used > 0:
				enemy_animator.attack(bat_status.next.monst_pow_used)
				pl_health_bar.set_health(bat_status.next.pl_stats.health)
				player_animator.hit()
			attack_heading.text = bat_status.next.next_action.flv_text
			action_cover.hide()
		
		if bat_status.defeat:
			enemy_animator.attack(bat_status.defeat.monst_pow_used)
			pl_health_bar.subtract_health(bat_status.defeat.monst_dmg)
			attack_heading.visible = false
			results_panel.show_defeat()
			player_animator.defeat()
			music_player.stop()
			
			ws.close()
			QuestState.clear_current()

	var state = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		return
	if state == WebSocketPeer.STATE_CLOSING or state == WebSocketPeer.STATE_CLOSED:
		return

func attack(power: int):
	# disable actions until response
	action_cover.show_attacking(power)
	player_animator.attack(power)
	ws.send_text("Attack::%d" % power)
	
func defend():
	# disable actions until response
	action_cover.show_defending()
	ws.send_text("Defend")

func _on_results_button_pressed():
	QuestState.clear_current()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	
func goto_home():	
	ws.close()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
