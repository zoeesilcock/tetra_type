class_name TetraBoard
extends Control

@export var key_scene : PackedScene
@export var cursor_scene : PackedScene

@export var wrap_around_cursor : bool
@export var reset_cursor_automatically : bool
@export var reset_cursor_after : int

var cursor : Panel
var keys : Dictionary
var current_position : Vector2i
var viewport : Viewport
var last_input_time : int
var row_extents : Dictionary
var col_extents : Dictionary

const LAYOUT = preload("res://layouts/english_alphabetical_layout.gd").ENGLISH_ALPHABETICAL_LAYOUT
const FIRST_LETTER = 65
const LAST_LETTER = 90

const CLOCKWISE_DIRECTIONS = [
	Vector2i.UP,
	Vector2i.RIGHT,
	Vector2i.DOWN,
	Vector2i.LEFT,
]

func _ready() -> void:
	viewport = get_viewport()

	_create_keys()
	_create_cursor()

	_set_cursor_position(Vector2i(0, 0))

func _process(_delta : float) -> void:
	if (reset_cursor_automatically and
		Time.get_ticks_msec() > last_input_time + reset_cursor_after and
		current_position != Vector2i.ZERO):
		_set_cursor_position(Vector2i.ZERO)

func _input(event: InputEvent) -> void:
	var motion : Vector2i = Vector2i.ZERO

	if event.is_action_pressed("ui_left"):
		motion = Vector2i.LEFT
	if event.is_action_pressed("ui_right"):
		motion = Vector2i.RIGHT
	if event.is_action_pressed("ui_up"):
		motion = Vector2i.UP
	if event.is_action_pressed("ui_down"):
		motion = Vector2i.DOWN

	if motion != Vector2i.ZERO:
		viewport.set_input_as_handled()
		last_input_time = Time.get_ticks_msec()
		_move_cursor(motion)

	if event.is_action_pressed("ui_accept"):
		viewport.set_input_as_handled()
		last_input_time = Time.get_ticks_msec()
		_trigger_current_key()

func _create_cursor() -> void:
	cursor = cursor_scene.instantiate()
	add_child(cursor)

func _move_cursor(motion : Vector2i) -> void:
	var next_position : Vector2i = current_position + motion

	if wrap_around_cursor && !keys.has(next_position):
		if motion.x != 0:
			var extents : Extent = row_extents[current_position.y]
			next_position.x = _offset_within_extent(current_position.x, motion.x, extents.min, extents.max)

		if motion.y != 0:
			var extents : Extent = col_extents[current_position.x]
			next_position.y = _offset_within_extent(current_position.y, motion.y, extents.min, extents.max)

	_set_cursor_position(next_position)

func _set_cursor_position(cursor_position : Vector2i) -> void:
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
	var board_position : Vector2i = Vector2i.ZERO
	var key_index : int = 0
	var direction : int = 0
	var distance : int = 0

	_reset_extents()

	while key_index < len(LAYOUT):
		for outer_index : int in range(distance + 1, 0, -1):
			# Break out of the outermost loop early if we overshoot.
			if key_index >= len(LAYOUT):
				return

			# Add the key.
			_add_key(LAYOUT[key_index], board_position)
			_add_to_extents(board_position)
			key_index += 1

			# Calculate next position.
			board_position = Vector2i.ZERO
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

func _add_key(keycode : Key, board_position : Vector2i) -> void:
	var key : TetraKey = _create_key(keycode)
	var key_size : Vector2 = key.custom_minimum_size
	var key_position : Vector2 = (Vector2(board_position) * key_size) + key_size * 4

	add_child(key)
	key.position = key_position
	keys[board_position] = key

func _create_key(keycode : Key) -> TetraKey:
	var key : TetraKey = key_scene.instantiate()
	key.label.text = char(keycode)
	key.keycode = keycode
	return key

func _reset_extents() -> void:
	col_extents = {}
	row_extents = {}

func _add_to_extents(board_position : Vector2i) -> void:
	if !col_extents.has(board_position.x):
		col_extents[board_position.x] = Extent.new()
	if !row_extents.has(board_position.y):
		row_extents[board_position.y] = Extent.new()

	if board_position.y < col_extents[board_position.x].min:
		col_extents[board_position.x].min = board_position.y
	if board_position.y > col_extents[board_position.x].max:
		col_extents[board_position.x].max = board_position.y

	if board_position.x < row_extents[board_position.y].min:
		row_extents[board_position.y].min = board_position.x
	if board_position.x > row_extents[board_position.y].max:
		row_extents[board_position.y].max = board_position.x

func _offset_within_extent(value : int, offset : int, min : int, max : int) -> int:
	var range_length : int = max - min + 1
	return (value - min + (offset % range_length) + range_length) % range_length + min
