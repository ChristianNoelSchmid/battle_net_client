extends Node

@export var card_scene: PackedScene
@export var type_texs: Array[Texture2D]

signal loading_toggled

var _guess_button: Button
var _cancel_button: Button

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

const COLUMN_CATS = ["players", "murder_weapons", "movies"]
var _resources: Dictionary

func _ready():
	_guess_button = get_node("GuessPanel/Buttons/GuessButton")
	_cancel_button = get_node("GuessPanel/Buttons/CancelButton")

	var file = FileAccess.open('res://assets/category_cards.json', FileAccess.READ)
	var text = file.get_as_text()
	_resources = JSON.parse_string(text)

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

func _process(_delta):
	if not _state_loaded:
		import_state()
		_state_loaded = true

# Imports all _cards found in the _resources JSON	
func import_cards():
	var columns = [
		[_resources[COLUMN_CATS[0]], get_node("ScrollContainer/Row/Column1")],
		[_resources[COLUMN_CATS[1]], get_node("ScrollContainer/Row/Column2")],
		[_resources[COLUMN_CATS[2]], get_node("ScrollContainer/Row/Column3")]
	]

	for col_idx in range(columns.size()): 
		_cards.push_back([])
		for row_idx in range(columns[col_idx][0].size()):
			var row = columns[col_idx][0][row_idx]

			var card_values = card_scene.instantiate()
			columns[col_idx][1].add_child(card_values)

			var img = load("res://assets/%s/%s" % [COLUMN_CATS[col_idx], row["img_path"]]) if row.has('img_path') else null
			var desc = row['flavor_text'] if row.has('flavor_text') else ''

			card_values.set_info(row["name"], desc, img, type_texs[col_idx])

			card_values.triggered.connect(func(): card_triggered(col_idx, row_idx))
			_cards[col_idx].push_back(card_values)

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
	if body.get_string_from_utf8() == "true":
		print("Success!")
	else:
		print("Failure!")

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
