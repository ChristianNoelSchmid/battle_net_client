extends Node

var _quest_type_panel: QuestTypePanel 
var _loading_panel: Control
var quest_button_pressed = false
@onready var _menu_button: TextureButton = $MenuHamburger
@onready var _menu: Control = $MenuHamburger/Menu

func _ready():
	_quest_type_panel = get_node("/root/Main/Background/QuestTypePanel")
	_quest_type_panel.hide()

	_loading_panel = get_node("/root/Main/LoadingPanel")
	_loading_panel.show()

	QuestState.initialize()
	GameState.initialize()

	QuestState.on_quest_created.connect(func(_i): on_quest_btn_pressed())

func _process(_delta):
	if GameState.is_initialized() && quest_button_pressed:
		quest_button_pressed = false
		# If the user doens't have a quest they're currently on,
		# open the available quest-type panel
		if !QuestState.state || QuestState.state.quest_type == -1:
			_quest_type_panel.set_available_quests(
				GameState.state.pl_exhausted == false, 
				GameState.state.pl_completed_daily_riddle == false && GameState.state.pl_completed_all_riddles == false
			)
			_quest_type_panel.show()

		# Otherwise, to battle!
		elif QuestState.state.quest_type == Config.BATTLE_QUEST_IDX:
			MainMusicPlayer.stop()
			get_tree().change_scene_to_file("res://scenes/battle_scene/battle_scene.tscn")
		elif QuestState.state.quest_type == Config.RIDDLE_QUEST_IDX:
			get_tree().change_scene_to_file("res://scenes/riddle_scene/riddle_scene.tscn")
		
	_loading_panel.visible = QuestState.is_loading() || GameState.is_loading()
	_menu.visible = _menu_button.button_pressed
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		_menu_button.button_pressed = false

# Signal Handlers
func on_quest_btn_pressed():
	if !quest_button_pressed:
		GameState.initialize()
		quest_button_pressed = true

func on_battle_btn_pressed():
	QuestState.create_monster()

func on_riddle_btn_pressed():
	QuestState.create_riddle()

func on_card_btn_pressed():
	get_tree().change_scene_to_file("res://scenes/card_menu/card_menu.tscn")

func on_logout_btn_pressed():
	QuestState.clear_current()
	Auth.logout()
	get_tree().change_scene_to_file("res://scenes/login_scene/login_scene.tscn")
