extends Node

var _game_state_http_request: HTTPRequest
var state = null
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
    state = JSON.parse_string(body.get_string_from_utf8())
    print("GameState: %s" % state)
    _loading = false