class_name TetraBoard
extends Control

@export var key_scene : PackedScene
@export var cursor_scene : PackedScene

var cursor : Panel
var keys : Dictionary
var current_position : Vector2

func _ready() -> void:
	_create_keys()
	_create_cursor()

	_set_cursor_position(Vector2(0, 0))

func _input(event: InputEvent) -> void:
	var motion : Vector2 = Vector2.ZERO

	if event.is_action_pressed("ui_left"):
		motion = Vector2.LEFT
	if event.is_action_pressed("ui_right"):
		motion = Vector2.RIGHT
	if event.is_action_pressed("ui_up"):
		motion = Vector2.UP
	if event.is_action_pressed("ui_down"):
		motion = Vector2.DOWN

	if motion != Vector2.ZERO:
		_set_cursor_position(current_position + motion)

func _create_cursor() -> void:
	cursor = cursor_scene.instantiate()
	add_child(cursor)

func _set_cursor_position(cursor_position : Vector2) -> void:
	if keys.has(cursor_position):
		current_position = cursor_position
		cursor.position = keys[current_position].position

func _create_keys() -> void:
	var row : int = -2
	var col : int = -2

	for letter_code : int in range(65, 91):
		var key : TetraKey = _create_key(char(letter_code))
		var key_size : Vector2 = key.custom_minimum_size

		# Hacky approach to get Z centered on the last row.
		if (char(letter_code) == "Z"):
			col += 2

		add_child(key)
		key.position = (Vector2(col, row) * key_size) + key_size * 2

		var key_coordinate : Vector2 = Vector2(col, row)
		keys[key_coordinate] = key

		col += 1
		if col > 2:
			col = -2
			row += 1

func _create_key(letter : String) -> TetraKey:
	var key : TetraKey = key_scene.instantiate()
	key.label.text = letter

	return key
