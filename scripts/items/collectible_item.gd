extends Area2D

@export var biome_id: String = "spring"
@export var item_id: String = "wood"
@export var amount: int = 1
@export var object_id: String = ""

@onready var sprite: Sprite2D = get_node_or_null("Sprite2D") as Sprite2D
@onready var collision_shape: CollisionShape2D = get_node_or_null("CollisionShape2D") as CollisionShape2D

var collected := false
var idle_tween: Tween
var base_position := Vector2.ZERO
var base_scale := Vector2.ONE

func _ready() -> void:
	if object_id == "":
		object_id = str(get_path())

	if GameState.is_world_object_collected(object_id):
		queue_free()
		return

	body_entered.connect(_on_body_entered)

	if sprite != null:
		base_position = sprite.position
		base_scale = sprite.scale
		start_idle_animation()
	else:
		print("Este collectible no tiene Sprite2D: ", name)


func start_idle_animation() -> void:
	if sprite == null:
		return

	idle_tween = create_tween()
	idle_tween.set_loops()

	idle_tween.tween_property(sprite, "position:y", base_position.y - 5, 0.45)
	idle_tween.tween_property(sprite, "position:y", base_position.y + 3, 0.45)
	idle_tween.tween_property(sprite, "position:y", base_position.y, 0.35)


func _on_body_entered(body: Node2D) -> void:
	if collected:
		return

	if not body.is_in_group("player"):
		return

	collected = true

	var was_added := MissionManager.add_item(biome_id, item_id, amount)

	if not was_added:
		collected = false
		return

	AudioManager.play_collect()
	GameState.mark_world_object_collected(object_id)

	collect_animation()


func collect_animation() -> void:
	if idle_tween:
		idle_tween.kill()

	set_deferred("monitoring", false)

	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

	if sprite == null:
		queue_free()
		return

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(sprite, "position:y", sprite.position.y - 18, 0.25)
	tween.tween_property(sprite, "scale", base_scale * 1.35, 0.25)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.25)

	await tween.finished

	queue_free()
