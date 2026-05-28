extends Node2D

@onready var mission_popup: CanvasLayer = get_node_or_null("MissionPopup")
@onready var mission_tracker_hud: CanvasLayer = get_node_or_null("MissionTrackerHUD")
@onready var heavy_rain: GPUParticles2D = get_node_or_null("HeavyRain") as GPUParticles2D

func _ready() -> void:
	AudioManager.play_background_music()

	if heavy_rain != null:
		heavy_rain.emitting = false

	if not MissionManager.mission_completed.is_connected(_on_mission_completed):
		MissionManager.mission_completed.connect(_on_mission_completed)

	handle_puzzle_return()


func handle_puzzle_return() -> void:
	if not GameState.should_return_from_puzzle:
		return

	var player = get_node_or_null("Player")

	if player != null:
		player.global_position = GameState.puzzle_return_position
		GameState.set_respawn_position(GameState.puzzle_return_position)

	GameState.consume_puzzle_return()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("mission"):
		if mission_popup != null:
			mission_popup.show_mission("spring")


func _on_mission_completed(biome_id: String) -> void:
	if biome_id == "spring":
		print("Mission completed. The door is now open.")

	if biome_id == "winter":
		start_storm()


func start_storm() -> void:
	AudioManager.play_rain()

	if heavy_rain != null:
		heavy_rain.emitting = true
		heavy_rain.restart()
