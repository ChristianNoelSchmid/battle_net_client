extends Node

@export var card_scene: PackedScene
@export var type_texs: Array[Texture2D]

signal loading_toggled

@onready var _msg_panel = $GuessPanel
@onready var _button_panel = $GuessPanel/VBoxContainer/Buttons
@onready var _already_guessed_label = $GuessPanel/VBoxContainer/AlreadyGuessedLabel
@onready var _guess_button: Button = $GuessPanel/VBoxContainer/Buttons/GuessButton
@onready var _cancel_button: Button = $GuessPanel/VBoxContainer/Buttons/CancelButton
@onready var _win_display = $WinDisplay
@onready var _incorrect_display = $IncorrectDisplay

var _cards = []
var _state_loaded = false
var _guessing_scheme_active = false

var _state_http_request: HTTPRequest
var _confirm_http_request: HTTPRequest
var _guess_http_request: HTTPRequest

# The column and row considered, for the consider scheme
var _considered_col_row: Array[int] = []

# The columns and rows considered, for the guessed scheme
var _guessed_col_rows = [-1, -1, -1]
var _resources: Dictionary

func _ready():
	_state_http_request = HTTPRequest.new()
	_state_http_request.request_completed.connect(_on_state_response)
	add_child(_state_http_request)

	_confirm_http_request = HTTPRequest.new()
	_confirm_http_request.request_completed.connect(_on_card_guessed_response)
	add_child(_confirm_http_request)

	_guess_http_request = HTTPRequest.new()
	_guess_http_request.request_completed.connect(_on_guess_response)
	add_child(_guess_http_request)

	loading_toggled.emit()
	import_cards()
	
	if GameState.state.pl_guessed_today:
		_button_panel.hide()
		_already_guessed_label.show()
		
	if GameState.state.player_won():
		_msg_panel.hide()

func _process(_delta):
	if not _state_loaded:
		import_state()
		_state_loaded = true

# Imports all _cards found in the _resources JSON	
func import_cards():
	var columns = [
		$ScrollContainer/Row/Column1,
		$ScrollContainer/Row/Column2,
		$ScrollContainer/Row/Column3
	]

	for col_idx in range(columns.size()): 
		_cards.push_back([])
		for idxs in Resources.get_cat_card_idxs():
			if idxs[0] == col_idx:
				var new_card = card_scene.instantiate()
				columns[col_idx].add_child(new_card)
				new_card.set_info(idxs[0], idxs[1])
				
				new_card.triggered.connect(card_triggered.bind(idxs[0], idxs[1]))
				_cards[idxs[0]].push_back(new_card)
	
	var margin = load("res://scenes/card_menu/margin.tscn").instantiate()
	columns[0].add_child(margin)

# Imports the current game state from the server
func import_state():
	loading_toggled.emit()
	_state_http_request.request("%s/game/state" % Config.URL_ROOT,
		["Authorization: Bearer %s" % Auth.access_token],
		HTTPClient.METHOD_GET
	)
	
func _on_state_response(_result, _response_code, _headers, body):
	# Parse the JSON contents and get the 'user_cards' state
	var json = JSON.parse_string(body.get_string_from_utf8())
	if GameState.state.player_won():
		for i in len(_cards):
			for j in len(_cards[i]):
				_cards[i][j].confirm_card()
		for idxs in GameState.state.target_cards:
			_cards[idxs.cat_idx][idxs.card_idx].win_card()
	for card_values in json['user_cards']:
		# Get the card being referenced
		var card = 	_cards[card_values['cat_idx']][card_values['card_idx']]
		# If the card is marked as confirmed, reflect that in the UI
		# Otherwise, toggle it as guessed
		if card_values['confirmed']: card.confirm_card()
		else: card.toggle_consider_status()

	loading_toggled.emit()

# Called when a resource card is pressed
func card_triggered(col, row): 
	# If the menu is in the consider scheme
	if not _guessing_scheme_active:
		# Store the column and row, to be processed after the request is made
		_considered_col_row = [col, row]

		# Send an update HTTP request
		print("Updating card %d, %d" % [col, row])
		_confirm_http_request.request("%s/game/update-card" % Config.URL_ROOT,
			["Authorization: Bearer %s" % Auth.access_token, "Content-Type: application/json"],
			HTTPClient.METHOD_POST,
			JSON.stringify({ "cat_idx": col, "card_idx": row, "confirmed": _cards[col][row].get_status() == Config.CARD_CONSIDERED })
		)
		loading_toggled.emit()

	# If the menu is in the guess scheme
	else:
		# Remove guessing UI from the currently toggled card (if one exists)
		if _guessed_col_rows[col] != -1:
			_cards[col][_guessed_col_rows[col]].set_is_being_guessed(false)

		# Determine if there is any active guessed card in the cache		
		if _guessed_col_rows[col] == row:
			_guessed_col_rows[col] = -1
		else:
			_guessed_col_rows[col] = row
			_cards[col][row].set_is_being_guessed(true)

		_guess_button.disabled = _guessed_col_rows.any(func(c): return c == -1)

func _on_card_guessed_response(_result, _response_code, _headers, _body):
	_cards[_considered_col_row[0]][_considered_col_row[1]].toggle_consider_status()
	_considered_col_row = []
	loading_toggled.emit()

## Toggled when the "Guess" button is pressed. Turns the guessing scheme on and off for the UI
func _on_guess_pressed():
	# If the guessing scheme is currently deactivated
	if not _guessing_scheme_active:
		# Deactivate the Guess Button - it will reactivate when three cards are picked
		_guess_button.disabled = true
		_cancel_button.visible = true
		_guessing_scheme_active = true
		
		# Set each card to it's Guess scheme UI
		for col in _cards:
			for card in col:
				card.toggle_guessing_scheme()
	else:
		_guess_http_request.request("%s/game/guess" % Config.URL_ROOT,
			["Authorization: Bearer %s" % Auth.access_token, "Content-Type: application/json"],
			HTTPClient.METHOD_POST,
			JSON.stringify(_guessed_col_rows)
		)
		_guess_button.disabled = false
		_cancel_button.visible = false
		for col in _cards:
			for card in col:
				card.toggle_guessing_scheme()

func _on_guess_response(_result, _response_code, _headers, body):
	var res = load("res://models/guess_result_model.gd").new()
	var contents = body.get_string_from_utf8()
	var json = JSON.parse_string(contents)
	print(contents)
	print(json)
	res.parse_variant(json)
	
	if res.incorrect:
		_incorrect_display.show()
	else:
		var tex1 = _cards[0][res.correct[0]].texture
		var tex2 = _cards[1][res.correct[1]].texture
		var tex3 = _cards[2][res.correct[2]].texture
		_win_display.display(tex1, tex2, tex3)

func _on_cancel_pressed():
	_guess_button.disabled = false
	_cancel_button.visible = false
	_guessing_scheme_active = false
	_guessed_col_rows = [-1, -1, -1]

	# Set each card to it's Guess scheme UI
	for col in _cards:
		for card in col:
			card.toggle_guessing_scheme()

func on_button_back_pressed():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")
