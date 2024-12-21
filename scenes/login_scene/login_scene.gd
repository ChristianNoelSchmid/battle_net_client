extends Node

@onready var input_username: LineEdit = $UI/VBox/HBoxUsername/LineEditUsername
@onready var input_password: LineEdit = $UI/VBox/HBoxPassword/LineEditPassword
@onready var _submit_btn: Button = $UI/VBox/Button
@onready var label: Label = $UI/VBox/Label

var cookie_regex: RegEx

func _ready():
	Auth.on_auth_success.connect(_on_auth_success)
	Auth.on_login_failure.connect(_on_login_failure)

func try_login():		
	Auth.try_login(input_username.text, input_password.text)

func _on_auth_success():
	MainMusicPlayer.play()
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _on_login_failure():
	label.text = "Uhoh! That didn't work. Please re-copy your token and try again."
	label.self_modulate = Color.RED
	input_username.modulate = Color.RED	
	input_password.modulate = Color.RED

func on_input(_new_text: String):
	input_username.modulate = Color.WHITE
	input_password.modulate = Color.WHITE

func _on_access_token_submit() -> void:
	Auth.try_set_access_token(DisplayServer.clipboard_get())
