extends TextureRect

@export var consider_texture: Texture2D
@export var confirmed_texture: Texture2D
@export var win_texture: Texture2D

@onready var _status_icon: TextureRect = $StatusIcon
@onready var _confirm_panel: Control = $ConfirmPanel
@onready var _confirm_text: Label = $ConfirmPanel/ConfirmText

signal triggered
var _status: int = Config.CARD_CONSIDERED
var _guessing: bool = false
var _mouse_over = false
var _consider_confirm_visible: bool = false
var _scrolled = false
var _item_rect_changed = 0.0

func _ready() -> void:
	get_parent().get_parent().item_rect_changed.connect(_on_item_rect_changed)
	
func _process(delta: float) -> void:
	if Input.is_action_just_released("mouse-left"):
		if _mouse_over && _item_rect_changed <= 0:
			if _status != Config.CARD_CONFIRMED:
				if _guessing: 
					triggered.emit()
				elif _consider_confirm_visible: 
					triggered.emit()
					_consider_confirm_visible = false
				else: 
					_consider_confirm_visible = true
		else:
			_consider_confirm_visible = false
			
	_confirm_panel.visible = _consider_confirm_visible && !_guessing
	if _item_rect_changed > 0 && !Input.is_action_pressed("mouse-left"):
		_item_rect_changed -= delta
	
func _on_item_rect_changed():
	_item_rect_changed = 0.1

### Getters/Setters ###
func set_info(cat_idx, card_idx): 
	texture = Resources.get_card_sprite(cat_idx, card_idx)

### Consider Scheme
func confirm_card():
	_status_icon.texture = confirmed_texture
	_status = Config.CARD_CONFIRMED
	
func win_card():
	_status_icon.texture = win_texture
	_status = Config.CARD_CONFIRMED

func toggle_consider_status():
	if _status == Config.CARD_CONFIRMED: return
	if _status == Config.CARD_CONSIDERED: 
		_status = Config.CARD_NOT_CONSIDERED
		_status_icon.texture = consider_texture
		_confirm_text.text = "Remove Guess"
	else:
		_status = Config.CARD_CONSIDERED
		_status_icon.texture = null
		_confirm_text.text = "Add Guess"

func get_status() -> int: return _status

### Guessing Scheme ###
func toggle_guessing_scheme():
	if not _guessing:
		modulate = Color.hex(0x999999)
		_guessing = true
	else:
		modulate = Color.WHITE
		_guessing = false

func set_is_being_guessed(being_guessed: bool):
	if being_guessed: modulate = Color.WHITE
	else: modulate = Color.hex(0x999999)

func _on_mouse_entered():
	_mouse_over = true
	
func _on_mouse_exited():
	_mouse_over = false
	
#func _is_mouse_over(): 
	#var mouse_pos = get_global_mouse_position()
	#var mouse_over = mouse_pos.x > _confirm_panel.global_position.x and mouse_pos.x < (_confirm_panel.global_position.x + _confirm_panel.get_global_rect().size.x)
	#mouse_over = mouse_over and mouse_pos.y > _confirm_panel.global_position.y and mouse_pos.y < (_confirm_panel.global_position.y + _confirm_panel.get_global_rect().size.y)
#
	#return mouse_over
