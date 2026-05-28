extends CharacterBody2D

@export var capture_ball_projectile_scene: PackedScene = preload("res://scenes/projectiles/CaptureBallProjectile.tscn")
@export var ladder_speed := 90.0

@onready var throw_point: Marker2D = $ThrowPoint
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var respawn_particles: GPUParticles2D = $RespawnParticles

const SPEED := 170.0
const JUMP_VELOCITY := -360.0
const GRAVITY := 980.0

var last_direction := Vector2.RIGHT
var is_crouching := false
var is_on_ladder := false
var ladder_layer: TileMapLayer = null

func _ready() -> void:
	print("Player listo")
	ladder_layer = get_tree().get_first_node_in_group("ladder_layer") as TileMapLayer

func _physics_process(delta: float) -> void:
	is_on_ladder = check_ladder()

	var direction := Input.get_axis("move_left", "move_right")
	var vertical_direction := Input.get_axis("move_up", "move_down")

	if is_on_ladder:
		velocity.y = vertical_direction * ladder_speed
		velocity.x = direction * SPEED

		if vertical_direction == 0:
			velocity.y = 0
	else:
		if not is_on_floor():
			velocity.y += GRAVITY * delta

		is_crouching = Input.is_action_pressed("crouch") and is_on_floor()

		if is_crouching:
			velocity.x = 0
		else:
			velocity.x = direction * SPEED

		if Input.is_action_just_pressed("jump") and is_on_floor() and not is_crouching:
			velocity.y = JUMP_VELOCITY

	if direction != 0:
		animated_sprite.flip_h = direction < 0

	if direction > 0:
		last_direction = Vector2.RIGHT
	elif direction < 0:
		last_direction = Vector2.LEFT

	update_animation(direction)
	move_and_slide()

func check_ladder() -> bool:
	if ladder_layer == null:
		return false

	var local_position := ladder_layer.to_local(global_position)
	var tile_position := ladder_layer.local_to_map(local_position)
	var tile_data := ladder_layer.get_cell_tile_data(tile_position)

	if tile_data == null:
		return false

	return tile_data.get_custom_data("is_ladder") == true

func throw_capture_ball() -> void:
	if not GameState.has_capture_ball:
		print("You need the Capture Ball first.")
		return

	if capture_ball_projectile_scene == null:
		print("No capture ball projectile scene assigned.")
		return

	AudioManager.play_pokeball_throw()

	var projectile = capture_ball_projectile_scene.instantiate()
	get_tree().current_scene.add_child(projectile)

	projectile.global_position = throw_point.global_position

	if projectile.has_method("setup"):
		projectile.setup(last_direction)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("throw_capture_ball"):
		throw_capture_ball()

func update_animation(direction: float) -> void:
	if is_on_ladder:
		if Input.get_axis("move_up", "move_down") != 0:
			play_animation("walk")
		else:
			play_animation("idle")
	elif is_crouching:
		play_animation("crouch")
	elif not is_on_floor():
		if velocity.y < 0:
			play_animation("jump")
		else:
			play_animation("fall")
	elif direction != 0:
		play_animation("walk")
	else:
		play_animation("idle")

func play_animation(animation_name: String) -> void:
	if animated_sprite.sprite_frames.has_animation(animation_name):
		if animated_sprite.animation != animation_name:
			animated_sprite.play(animation_name)
	else:
		if animated_sprite.sprite_frames.has_animation("idle"):
			animated_sprite.play("idle")

func _on_water_body_entered(body: Node2D) -> void:
	if body == self:
		respawn_player()

func respawn_player() -> void:
	AudioManager.play_fall()

	global_position = GameState.get_respawn_position()
	velocity = Vector2.ZERO
	play_respawn_effect()

func play_respawn_effect() -> void:
	if respawn_particles == null:
		return

	respawn_particles.emitting = false
	respawn_particles.restart()
	respawn_particles.emitting = true
