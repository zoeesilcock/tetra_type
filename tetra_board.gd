class_name TetraBoard
extends Control

@export var key_scene : PackedScene
@export var cursor_scene : PackedScene

@export var reset_cursor_automatically : bool
@export var reset_cursor_after : int

var cursor : Panel
var keys : Dictionary
var current_position : Vector2
var viewport : Viewport
var last_input_time : int

const LAYOUT = preload("res://layouts/english_alphabetical_layout.gd").ENGLISH_ALPHABETICAL_LAYOUT
const FIRST_LETTER = 65
const LAST_LETTER = 90

const CLOCKWISE_DIRECTIONS = [
	Vector2.UP,
	Vector2.RIGHT,
	Vector2.DOWN,
	Vector2.LEFT,
]

func _ready() -> void:
	viewport = get_viewport()

	_create_keys()
	_create_cursor()

	_set_cursor_position(Vector2(0, 0))

func _process(_delta : float) -> void:
	if (reset_cursor_automatically and
		Time.get_ticks_msec() > last_input_time + reset_cursor_after and
		current_position != Vector2.ZERO):
		_set_cursor_position(Vector2.ZERO)

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
		viewport.set_input_as_handled()
		last_input_time = Time.get_ticks_msec()
		_set_cursor_position(current_position + motion)

	if event.is_action_pressed("ui_accept"):
		viewport.set_input_as_handled()
		last_input_time = Time.get_ticks_msec()
		_trigger_current_key()

func _create_cursor() -> void:
	cursor = cursor_scene.instantiate()
	add_child(cursor)

func _set_cursor_position(cursor_position : Vector2) -> void:
	if keys.has(cursor_position):
		current_position = cursor_position
		cursor.position = keys[current_position].position

func _get_current_key() -> TetraKey:
	return keys[current_position]

func _trigger_current_key() -> void:
	var current_key : TetraKey = _get_current_key()
	var event : InputEventKey = InputEventKey.new()

	event.pressed = true
	event.unicode = current_key.keycode

	# Backspace doesn't work without a keycode.
	# Including a keycode for all characters risks
	# triggering any action bound to that character.
	if current_key.keycode == KEY_BACKSPACE:
		event.keycode = current_key.keycode

	Input.parse_input_event(event)

func _create_keys() -> void:
	var board_position : Vector2 = Vector2.ZERO
	var key_index : int = 0
	var direction : int = 0
	var distance : int = 0

	while key_index < len(LAYOUT):
		for outer_index : int in range(distance + 1, 0, -1):
			# Break out of the outermost loop early if we overshoot.
			if key_index >= len(LAYOUT):
				return

			# Add the key.
			_add_key(LAYOUT[key_index], board_position)
			key_index += 1

			# Calculate next position.
			board_position = Vector2.ZERO
			for inner_index : int in range(0, distance + 1):
				# We start by moving the distance in the current direction.
				var inner_direction : int = direction

				# But as the distance from the from the center increases,
				# we have to include the next direction, more times
				# for each step away from the center.
				#
				# Example: At 3 steps from center, facing up we do:
				# * up up up
				# * up up right
				# * up right right
				if inner_index > outer_index - 1:
					inner_direction = (direction + 1) % len(CLOCKWISE_DIRECTIONS)

				# Set the next position.
				board_position += CLOCKWISE_DIRECTIONS[inner_direction]

		# Go to next direction and increase distance if we've completed a rotation.
		direction += 1
		if direction == len(CLOCKWISE_DIRECTIONS):
			direction = 0
			distance += 1

func _add_key(keycode : Key, board_position : Vector2) -> void:
	var key : TetraKey = _create_key(keycode)
	var key_size : Vector2 = key.custom_minimum_size
	var key_position : Vector2 = (board_position * key_size) + key_size * 4

	add_child(key)
	key.position = key_position
	keys[board_position] = key

func _create_key(keycode : Key) -> TetraKey:
	var key : TetraKey = key_scene.instantiate()
	key.label.text = char(keycode)
	key.keycode = keycode
	return key
