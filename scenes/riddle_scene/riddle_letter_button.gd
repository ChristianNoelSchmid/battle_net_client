extends Button

var _letter: String

signal on_select(btn)

func set_letter(value: String):
	text = value
	_letter = value

func get_letter():
	return _letter

func on_pressed() -> void:
	on_select.emit(self)
	
