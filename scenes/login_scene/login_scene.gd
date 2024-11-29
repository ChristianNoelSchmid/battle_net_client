extends Node2D

@onready var input_username: LineEdit = $UI/VBox/HBoxUsername/LineEditUsername
@onready var input_password: LineEdit = $UI/VBox/HBoxPassword/LineEditPassword

var cookie_regex: RegEx

func _ready():
	Auth.on_auth_success.connect(_on_auth_success)
	Auth.on_login_failure.connect(_on_login_failure)

func _process(_delta):
	if Input.is_action_just_pressed("submit"):
		try_login()

func try_login():		
	Auth.try_login(input_username.text, input_password.text)

func _on_auth_success():
	get_tree().change_scene_to_file("res://scenes/main_menu/main_menu.tscn")

func _on_login_failure(_msg: String):
	input_username.modulate = Color.RED	
	input_password.modulate = Color.RED

func on_input(_new_text: String):
	input_username.modulate = Color.WHITE
	input_password.modulate = Color.WHITE
