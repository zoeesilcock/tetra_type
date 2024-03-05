class_name TetraBoard
extends Control

@export var grid : GridContainer
@export var key_scene : PackedScene

var _keys : Dictionary
var _current_position : Vector2

func _ready() -> void:
	_create_keys()
	_current_position = Vector2(2, 2)

func _create_keys() -> void:
	var row : int = 0
	var col : int = 0

	for letter_code : int in range(65, 91):
		var key : TetraKey = _create_key(char(letter_code))

		# Hacky approach to get Z centered on the last row.
		if (char(letter_code) == "Z"):
			grid.add_child(_create_key(char(32)))
			grid.add_child(_create_key(char(32)))
			col += 2

		grid.add_child(key)

		var key_coordinate : Vector2 = Vector2(row, col)
		_keys[key_coordinate] = key

		col += 1
		if col > 4:
			col = 0
			row += 1

func _create_key(letter : String) -> TetraKey:
	var key : TetraKey = key_scene.instantiate()
	key.label.text = letter

	return key
