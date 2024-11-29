extends Node

var _game_state_http_request: HTTPRequest
var state: GameStateModel = null
var _loading = false

func is_loading(): return _loading

func initialize():
	_game_state_http_request = HTTPRequest.new()
	_game_state_http_request.request_completed.connect(_on_game_state_response)
	add_child(_game_state_http_request)
	
	_get_game_state()
	_loading = true

func _get_game_state():
	_game_state_http_request.request(
		"%s/game/state" % Config.URL_ROOT,
		["Authorization: Bearer %s" % Auth.access_token, "Content-Type: application/json"]
	)

func _on_game_state_response(_result, _response_code, _headers, body):
	var variant = JSON.parse_string(body.get_string_from_utf8())
	state = load("res://models/game_state_model.gd").new()
	state.parse_variant(variant)
	_loading = false
