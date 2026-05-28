extends Area2D

@export var required_biome_id: String = "winter"
@export var final_scene_path: String = "res://scenes/levels/FinalCutscene.tscn"

var changing_scene := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if changing_scene:
		return

	if not body.is_in_group("player"):
		return

	if not MissionManager.is_mission_complete(required_biome_id):
		print("Primero debes completar la misión de Winter.")
		return

	if not ResourceLoader.exists(final_scene_path):
		print("No existe la escena final: ", final_scene_path)
		return

	changing_scene = true
	get_tree().call_deferred("change_scene_to_file", final_scene_path)
