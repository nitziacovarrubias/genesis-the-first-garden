extends Node2D

@export var total_ark_pieces := 13
@export var fallback_world_scene_path: String = "res://scenes/player/World.tscn"
@export var reveal_time := 1.2

@onready var mission_tracker_hud = $MissionTrackerHUD2
@onready var pieces_container = $PuzzleBoard/Pieces
@onready var silhouette = $PuzzleBoard/Silhouette
@onready var final_ark = $PuzzleBoard/FinalArk

var placed_ark_pieces := 0
var placed_piece_ids := {}
var puzzle_completed := false

func _ready() -> void:
	update_ark_progress()

	if final_ark != null:
		final_ark.visible = false
		final_ark.position = silhouette.position
		final_ark.scale = silhouette.scale

func register_ark_piece_placed(piece_id: String) -> void:
	if placed_piece_ids.has(piece_id):
		return

	if puzzle_completed:
		return

	placed_piece_ids[piece_id] = true
	placed_ark_pieces += 1

	update_ark_progress()

	if placed_ark_pieces >= total_ark_pieces:
		puzzle_completed = true
		await reveal_completed_ark()
		complete_puzzle()

func update_ark_progress() -> void:
	if mission_tracker_hud == null:
		print("No se encontró MissionTrackerHUD2")
		return

	mission_tracker_hud.set_ark_progress(placed_ark_pieces, total_ark_pieces)

func reveal_completed_ark() -> void:
	if silhouette != null:
		silhouette.visible = false

	if pieces_container != null:
		pieces_container.visible = false

	if final_ark != null:
		final_ark.visible = true

	await get_tree().create_timer(reveal_time).timeout

func complete_puzzle() -> void:
	GameState.complete_spring_puzzle()

	if GameState.world_scene_before_puzzle != "":
		get_tree().change_scene_to_file(GameState.world_scene_before_puzzle)
	else:
		get_tree().change_scene_to_file(fallback_world_scene_path)

func _on_skip_pressed() -> void:
	if puzzle_completed:
		return

	puzzle_completed = true
	await reveal_completed_ark()
	complete_puzzle()
