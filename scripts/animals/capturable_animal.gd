extends Area2D

@export var biome_id: String = "summer"
@export var animal_id: String = "sheep"
@export var display_name: String = "Sheep"
@export var amount: int = 1
@export var object_id: String = ""

@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label

var captured := false
var idle_tween: Tween

func _ready() -> void:
	if object_id == "":
		object_id = str(get_path())

	if GameState.is_world_object_collected(object_id):
		queue_free()
		return

	add_to_group("capturable_animals")

	if label != null:
		label.text = display_name
		label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		label.position = label.position.round()

	start_idle_animation()

func start_idle_animation() -> void:
	idle_tween = create_tween()
	idle_tween.set_loops()

	idle_tween.tween_property(sprite, "scale", sprite.scale * 1.06, 0.5)
	idle_tween.tween_property(sprite, "scale", sprite.scale, 0.5)

func capture() -> void:
	if captured:
		return

	if not GameState.has_capture_ball:
		return

	captured = true

	var was_added := MissionManager.add_item(biome_id, animal_id, amount)

	if not was_added:
		captured = false
		return

	AudioManager.play_collect()
	GameState.mark_world_object_collected(object_id)

	if idle_tween:
		idle_tween.kill()

	set_deferred("monitoring", false)

	if collision_shape != null:
		collision_shape.set_deferred("disabled", true)

	var tween := create_tween()
	tween.set_parallel(true)

	tween.tween_property(sprite, "scale", sprite.scale * 1.5, 0.25)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.25)

	if label != null:
		tween.tween_property(label, "modulate:a", 0.0, 0.25)

	await tween.finished

	queue_free()
