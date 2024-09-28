extends Node

var _create_riddle_request: HTTPRequest
var _create_monster_request: HTTPRequest
var _get_current_quest_request: HTTPRequest

var _state

# Invoked when a new quest is created
signal on_quest_created(quest_type: int)
signal on_quest_loaded()

const MONSTER_QUEST = 0
const RIDDLE_QUEST = 1

var _loading = false

func is_loading(): return _loading

func initialize():
	_create_monster_request = HTTPRequest.new()
	_create_monster_request.request_completed.connect(_on_create_quest_response)
	add_child(_create_monster_request)

	_create_riddle_request = HTTPRequest.new()
	_create_riddle_request.request_completed.connect(_on_create_quest_response)
	add_child(_create_riddle_request)

	_get_current_quest_request = HTTPRequest.new()
	_get_current_quest_request.request_completed.connect(_on_get_current_quest_response)
	add_child(_get_current_quest_request)

	_get_current_quest()

## Returns the type of quest the user is on,
## or -1 if the user is not on a quest
func get_quest_type():
	if _state == null:
		return -1
	else:
		return _state.quest_type

## Clears the current quest
func clear_current():
	_state = null

func _get_current_quest():
	_get_current_quest_request.request(
		"%s/quest/current" % Config.URL_ROOT, 
		["Authorization: Bearer %s" % Auth.access_token],
		HTTPClient.METHOD_GET
	)
	_loading = true

func create_monster():
	if _state != null:
		printerr("Attempted to start quest when one already exists")
		return
	_create_monster_request.request(
		"%s/quest/create/%d" % [Config.URL_ROOT, MONSTER_QUEST], 
		["Authorization: Bearer %s" % Auth.access_token],
		HTTPClient.METHOD_POST
	)
	_loading = true

func create_riddle():
	if _state != null:
		printerr("Attempted to start quest when one already exists")
		return
	_create_monster_request.request(
		"%s/quest/create/%d" % [Config.URL_ROOT, RIDDLE_QUEST], 
		["Authorization: Bearer %s" % Auth.access_token],
		HTTPClient.METHOD_POST
	)
	_loading = true

func _on_create_quest_response(_result, _response_code, _headers, body):
	if _response_code != 200:
		printerr("Failed to create quest: %s" % body.get_string_from_utf8())
		return

	var json = body.get_string_from_utf8()
	_state = JSON.parse_string(json)
	on_quest_created.emit(_state.quest_type)
	print("QuestState: %s" % _state)
	_loading = false

func _on_get_current_quest_response(_result, response_code, _headers, body):
	_loading = false
	if response_code == 404:
		return
	if response_code != 200:
		printerr("Failed to get current quest: Code: %d, Body: %s" % [ response_code, body.get_string_from_utf8() ])
		return

	var json = body.get_string_from_utf8()
	_state = JSON.parse_string(json)	
	print("QuestState: %s" % json)
	