extends Node

@onready var riddle_label = $Panel/VBoxContainer/RiddleLabel
@onready var results_panel = $"Results Panel"
@onready var entry = $Panel/VBoxContainer/HBoxContainer/LineEdit

var _guess_http_request: HTTPRequest

func _ready() -> void:
	riddle_label.text = QuestState.state.riddle_state.text

	_guess_http_request = HTTPRequest.new()
	_guess_http_request.request_completed.connect(_on_guess_response)
	add_child(_guess_http_request)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _on_submit():
	var route = ("%s/quest/guess-riddle/%s" % [Config.URL_ROOT, entry.text.uri_encode()])
	_guess_http_request.request(route,
		["Authorization: Bearer %s" % Auth.access_token],
		HTTPClient.METHOD_POST
	)

func _on_guess_response(_result, _response_code, _headers, body):
	# Parse the JSON contents and get the 'user_cards' state
	var json = JSON.parse_string(body.get_string_from_utf8())
	var status = load("res://models/riddle_guess_result_model.gd").new()
	status.parse_variant(json)
	if status.incorrect:
		pass
	else:
		results_panel.show_victory([status.correct.card.cat_idx, status.correct.card.card_idx])
		QuestState.clear_current()

func _on_goto_home():	
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
