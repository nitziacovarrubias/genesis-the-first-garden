extends Area2D

@export var biome_id: String = "winter"
@export var person_id: String = "noahs_wife"
@export var display_name: String = "Noah's Wife"
@export var amount: int = 1

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var collected := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if not body.is_in_group("player"):
		return

	collected = true

	var was_added := MissionManager.add_item(biome_id, person_id, amount)

	if not was_added:
		collected = false
		return

	AudioManager.play_collect()

	set_deferred("monitoring", false)

	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

	queue_free()
