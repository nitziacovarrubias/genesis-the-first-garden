extends Node2D

@export var total_ark_pieces := 13
@export var fallback_world_scene_path: String = "res://scenes/player/World.tscn"

@onready var mission_tracker_hud = $MissionTrackerHUD2

var placed_ark_pieces := 0
var placed_piece_ids := {}

func _ready() -> void:
	update_ark_progress()

func register_ark_piece_placed(piece_id: String) -> void:
	if placed_piece_ids.has(piece_id):
		return

	placed_piece_ids[piece_id] = true
	placed_ark_pieces += 1

	update_ark_progress()

	if placed_ark_pieces >= total_ark_pieces:
		complete_puzzle()

func update_ark_progress() -> void:
	if mission_tracker_hud == null:
		print("No se encontró MissionTrackerHUD2")
		return

	mission_tracker_hud.set_ark_progress(placed_ark_pieces, total_ark_pieces)

func complete_puzzle() -> void:
	GameState.complete_spring_puzzle()

	if GameState.world_scene_before_puzzle != "":
		get_tree().change_scene_to_file(GameState.world_scene_before_puzzle)
	else:
		get_tree().change_scene_to_file(fallback_world_scene_path)

func _on_skip_pressed() -> void:
	complete_puzzle()
