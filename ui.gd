extends CanvasLayer

@export var text_input : TextEdit

func _ready() -> void:
	text_input.grab_focus()
