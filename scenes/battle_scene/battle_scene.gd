extends Node 

var ws: WebSocketPeer
var attack_heading: Label

func _ready():
	attack_heading = find_child("AttackHeading", true)
	ws = WebSocketPeer.new()
	var err = ws.connect_to_url("ws://127.0.0.1:3005/battle")
	if err != OK:
		print(err)


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
			if "Next" in json:
				attack_heading.text = json["Next"]["next_action"]["flv_text"]
			elif "Victory" in json:
				print("Victory!")
				ws.close()
				QuestState.clear_current()
				get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
			elif "Defeat" in json:
				print("Defeat!")
				ws.close()
				QuestState.clear_current()
				get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

	var state = ws.get_ready_state()
	if state == WebSocketPeer.STATE_OPEN:
		return
	if state == WebSocketPeer.STATE_CLOSING or state == WebSocketPeer.STATE_CLOSED:
		return

func on_send_message(text: String):
	ws.send_text(text)