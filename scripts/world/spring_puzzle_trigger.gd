extends Area2D

@export var puzzle_scene_path: String = "res://scenes/levels/Stage2Puzzle.tscn"

var changing_scene := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	MissionManager.mission_completed.connect(_on_mission_completed)

func _on_body_entered(body: Node2D) -> void:
	_try_open_puzzle(body)

func _on_mission_completed(biome_id: String) -> void:
	if biome_id != "spring":
		return

	for body in get_overlapping_bodies():
		_try_open_puzzle(body)

func _try_open_puzzle(body: Node2D) -> void:
	if changing_scene:
		return

	if not body.is_in_group("player"):
		return

	if not MissionManager.is_mission_complete("spring"):
		print("Primero debes terminar la misión de Spring.")
		return

	if GameState.has_completed_spring_puzzle():
		return

	if not ResourceLoader.exists(puzzle_scene_path):
		print("No existe la escena del puzzle: ", puzzle_scene_path)
		return

	changing_scene = true

	var current_scene_path := get_tree().current_scene.scene_file_path

	# Guarda la posición final de Spring, para regresar ahí después del puzzle.
	GameState.prepare_spring_puzzle(current_scene_path, body.global_position)

	get_tree().call_deferred("change_scene_to_file", puzzle_scene_path)
