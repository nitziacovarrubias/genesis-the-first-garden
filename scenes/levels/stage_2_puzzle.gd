extends Node2D

@export var next_scene_path: String = "res://scenes/core/Credits.tscn"

@onready var mission_popup = $MissionPopup2
@onready var mission_complete_popup = $MissionCompletePopup2
@onready var tracker = $MissionTrackerHUD2
@onready var pieces_container = $PuzzleBoard/Pieces

var total_pieces: int = 0
var placed_pieces: int = 0

func _ready() -> void:
	total_pieces = pieces_container.get_child_count()
	placed_pieces = 0

	# Inicializar tracker
	tracker.set_total_pieces(total_pieces)
	tracker.set_progress(0)

	# Conectar piezas
	for piece in pieces_container.get_children():
		if piece.has_signal("placed_correctly"):
			piece.placed_correctly.connect(_on_piece_placed)

	# Conectar popup final
	mission_complete_popup.continue_requested.connect(_on_continue_after_complete)

	# Mostrar popup inicial
	mission_popup.show_puzzle_mission()


func _on_piece_placed() -> void:
	placed_pieces += 1
	tracker.add_piece()

	if placed_pieces >= total_pieces:
		mission_complete_popup.show_puzzle_complete()


func _on_continue_after_complete() -> void:
	get_tree().change_scene_to_file(next_scene_path)
