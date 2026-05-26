extends Area2D

signal placed_correctly

@export var target_slot_path: NodePath
@export var snap_distance: float = 80.0

var dragging = false
var placed = false

var original_scale: Vector2
var grab_local_pos: Vector2 = Vector2.ZERO
var scale_big: Vector2 = Vector2(0.38, 0.38)

func _ready():
	input_pickable = true
	original_scale = scale

func _process(_delta):
	if dragging and not placed:
		global_position = get_global_mouse_position() - (grab_local_pos * scale)

func _input_event(_viewport, event, _shape_idx):
	if placed:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			grab_local_pos = to_local(get_global_mouse_position())
			dragging = true
			scale = scale_big
			z_index = 100
			global_position = get_global_mouse_position() - (grab_local_pos * scale)

func _unhandled_input(event):
	if placed:
		return

	if dragging and event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			dragging = false
			check_placement()

func check_placement():
	var slot = get_node_or_null(target_slot_path)

	if slot == null:
		scale = original_scale
		z_index = 0
		return

	if global_position.distance_to(slot.global_position) <= snap_distance:
		global_position = slot.global_position
		scale = scale_big
		z_index = 0
		placed = true
		input_pickable = false
		emit_signal("placed_correctly")
	else:
		scale = original_scale
		z_index = 0
