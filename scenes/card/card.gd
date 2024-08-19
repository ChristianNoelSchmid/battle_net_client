extends TextureRect 

@export var consider_texture: Texture2D
@export var confirmed_texture: Texture2D

var _title_label: Label
var _desc_label: Label
var _image: TextureRect
var _type_icon: TextureRect
var _status_icon: TextureRect
var _confirm_panel: Control
var _confirm_text: Label

signal triggered
var _status: int = Config.CARD_CONSIDERED
var _guessing: bool = false

var _consider_confirm_visible: bool = false

func _ready():
	_title_label = get_node("Title")
	_desc_label = get_node("Description")
	_image = get_node("Image")
	_type_icon = get_node("TypeIcon")
	_status_icon = get_node("StatusIcon")
	_confirm_panel = get_node("ConfirmPanel")
	_confirm_text = get_node("ConfirmPanel/ConfirmText")

func _process(_delta):
	if _status != Config.CARD_CONFIRMED and Input.is_action_just_pressed('mouse-left'):
		if _is_mouse_over():
			if _guessing: triggered.emit()
			elif _consider_confirm_visible: 
				triggered.emit()
				_consider_confirm_visible = false
			else: _consider_confirm_visible = true
		else:
			_consider_confirm_visible = false

		_confirm_panel.visible = _consider_confirm_visible

### Getters/Setters ###
func set_info(title: String, desc: String, img_tex: Texture2D, type_tex: Texture2D): 
	_title_label.text = title
	_desc_label.text = desc
	_image.texture = img_tex
	_type_icon.texture = type_tex


### Consider Scheme
func confirm_card():
	_status_icon.texture = confirmed_texture
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

func _is_mouse_over(): 
	var mouse_pos = get_global_mouse_position()
	var mouse_over = mouse_pos.x > _confirm_panel.global_position.x and mouse_pos.x < (_confirm_panel.global_position.x + _confirm_panel.get_global_rect().size.x)
	mouse_over = mouse_over and mouse_pos.y > _confirm_panel.global_position.y and mouse_pos.y < (_confirm_panel.global_position.y + _confirm_panel.get_global_rect().size.y)

	return mouse_over

