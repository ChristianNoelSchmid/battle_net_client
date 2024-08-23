extends Node

var _game_state_http_request: HTTPRequest
var _quest_state_http_request: HTTPRequest
var _start_quest_request: HTTPRequest

var _quest_type_panel: QuestTypePanel 
var _loading_panel: Control

func _ready():
	_quest_type_panel = get_node("/root/Main/Background/QuestTypePanel")
	_quest_type_panel.hide()

	_loading_panel = get_node("/root/Main/LoadingPanel")
	_loading_panel.show()

	_game_state_http_request = HTTPRequest.new()
	_game_state_http_request.request_completed.connect(_on_game_state_response)
	add_child(_game_state_http_request)

	_quest_state_http_request = HTTPRequest.new()
	_quest_state_http_request.request_completed.connect(_on_quest_state_response)
	add_child(_quest_state_http_request)

	_start_quest_request = HTTPRequest.new()
	_start_quest_request.request_completed.connect(_on_start_quest_response)
	add_child(_start_quest_request)

	_game_state_http_request.request("%s/game/state" % Config.URL_ROOT,
		["Authorization: Bearer %s" % Auth.access_token, "Content-Type: application/json"]
	)
	_quest_state_http_request.request("%s/quest/current" % Config.URL_ROOT,
		["Authorization: Bearer %s" % Auth.access_token, "Content-Type: application/json"]
	)

# Signal Handlers
func on_quest_btn_pressed():
	_quest_type_panel.set_available_quests(
	State.game_state.pl_exhausted == false, 
		State.game_state.pl_completed_riddle == false
	)

	if State.quest_state == null:
		_quest_type_panel.show()
	else:
		_loading_panel.visible = true
		get_tree().change_scene_to_file("res://scenes/battle_scene/battle_scene.tscn")

func on_battle_btn_pressed():
	if State.quest_state == null:
		_start_quest_request.request(
			"%s/quest/create/%d" % [Config.URL_ROOT, Config.BATTLE_QUEST_IDX],
			["Authorization: Bearer %s" % Auth.access_token, "Content-Type: application/json"],
			HTTPClient.METHOD_POST,
		)
		_loading_panel.visible = true

func on_riddle_btn_pressed():
	if State.quest_state == null:
		_start_quest_request.request(
			"%s/quest/create/%d" % [Config.URL_ROOT, Config.RIDDLE_QUEST_IDX],
			["Authorization: Bearer %s" % Auth.access_token, "Content-Type: application/json"],
			HTTPClient.METHOD_POST,
		)
		_loading_panel.visible = true

# HTTP Response Handlers
func _on_game_state_response(_result, _response_code, _headers, _body):
	State.game_state = JSON.parse_string(_body.get_string_from_utf8())
	print("Game State: %s" % State.game_state)

func _on_quest_state_response(_result, _response_code, _headers, _body):
	if _response_code != 404:
		State.quest_state = JSON.parse_string(_body.get_string_from_utf8())
	print("Quest State: %s" % State.quest_state)
	_loading_panel.visible = false

func _on_start_quest_response(_result, _response_code, _headers, _body):
	State.quest_state = JSON.parse_string(_body.get_string_from_utf8())
	print("Quest Started! %s" % State.quest_state)
	get_tree().change_scene_to_file("res://scenes/battle_scene/battle_scene.tscn")
