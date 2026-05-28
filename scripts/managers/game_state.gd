extends Node

signal capture_ball_collected
signal respawn_point_changed(new_position: Vector2)

var has_capture_ball := false
var current_respawn_position := Vector2(70, -200)

# Control del puzzle después de Spring
var spring_puzzle_completed := false
var world_scene_before_puzzle := ""
var puzzle_return_position := Vector2.ZERO
var should_return_from_puzzle := false

# Objetos recolectados en el mundo para que no reaparezcan al recargar World
var collected_world_objects := {}

func collect_capture_ball() -> void:
	has_capture_ball = true
	capture_ball_collected.emit()

func set_respawn_position(new_position: Vector2) -> void:
	current_respawn_position = new_position
	respawn_point_changed.emit(new_position)

func get_respawn_position() -> Vector2:
	return current_respawn_position

func prepare_spring_puzzle(world_scene_path: String, return_position: Vector2) -> void:
	world_scene_before_puzzle = world_scene_path
	puzzle_return_position = return_position

func complete_spring_puzzle() -> void:
	spring_puzzle_completed = true
	should_return_from_puzzle = true

func has_completed_spring_puzzle() -> bool:
	return spring_puzzle_completed

func consume_puzzle_return() -> void:
	should_return_from_puzzle = false

func mark_world_object_collected(object_id: String) -> void:
	collected_world_objects[object_id] = true

func is_world_object_collected(object_id: String) -> bool:
	return collected_world_objects.has(object_id)
