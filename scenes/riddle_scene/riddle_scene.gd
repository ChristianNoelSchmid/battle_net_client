extends Node

@onready var riddle_label = $Background/RiddleLabel
@onready var results_panel = $ResultsPanel
@onready var entry = $Background/VBoxContainer/HBoxContainer/LineEdit
@onready var backspace_btn = $Background/VBoxContainer/HBoxContainer/Backspace
@onready var riddle_button_panel = $Background/VBoxContainer/LetterButtonPanel
@onready var _tmpl_riddle_letter_btn = $Background/VBoxContainer/LetterButtonPanel/RiddleLetterButton
@onready var _loading_panel = $LoadingPanel

var _guess_http_request: HTTPRequest

func _ready() -> void:
	riddle_label.text = QuestState.state.riddle_state.text

	_guess_http_request = HTTPRequest.new()
	_guess_http_request.request_completed.connect(_on_guess_response)
	add_child(_guess_http_request)
	
	for letter in QuestState.state.riddle_state.ans_scramb:
		_create_letter_button(letter)
	
func _process(_delta) -> void:
	if entry.has_focus() && Input.is_action_just_pressed('submit'):
		_on_submit()

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _on_submit():
	_loading_panel.show()
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
		entry.self_modulate = Color.RED
	else:
		results_panel.show_victory(status.correct.card)
		QuestState.clear_current()
	_loading_panel.hide()

func goto_home():	
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
	
func _create_letter_button(letter: String):
	var btn: Button = _tmpl_riddle_letter_btn.duplicate()
	btn.visible = true
	btn.set_letter(letter)
	riddle_button_panel.add_child(btn)
	btn.pressed.connect(_on_letter_btn_pressed.bind(btn))

func _on_letter_btn_pressed(btn):
	entry.self_modulate = Color.WHITE;
	entry.text += btn.get_letter()
	riddle_button_panel.remove_child(btn)
	backspace_btn.disabled = false

func _on_backspace():
	entry.self_modulate = Color.WHITE;
	_create_letter_button(entry.text[len(entry.text) - 1])
	entry.text = entry.text.substr(0, len(entry.text) - 1)
	if len(entry.text) == 0:
		backspace_btn.disabled = true
