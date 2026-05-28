extends Node2D

@export var menu_scene_path: String = "res://scenes/ui/MainMenu.tscn"
@export var ark_travel_distance: float = 950.0
@export var ark_travel_time: float = 10.0
@export var wave_strength: float = 8.0
@export var wave_speed: float = 2.4
@export var heavy_rain_path: NodePath = NodePath("HeavyRain")

@onready var ark: Sprite2D = $Ark
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var credits_panel: Control = $CanvasLayer/CreditsPanel
@onready var credits_container: VBoxContainer = $CanvasLayer/CreditsPanel/VBoxContainer
@onready var rain_particles: GPUParticles2D = get_node_or_null(heavy_rain_path) as GPUParticles2D

var ark_start_y := 0.0
var time_passed := 0.0
var cutscene_finished := false

func _ready() -> void:
	AudioManager.stop_music()
	AudioManager.play_final_music()
	AudioManager.play_rain(-6.0)

	ark_start_y = ark.position.y

	setup_credits()
	setup_rain()
	start_final_animation()

func _process(delta: float) -> void:
	if cutscene_finished:
		return

	time_passed += delta
	ark.position.y = ark_start_y + sin(time_passed * wave_speed) * wave_strength

func setup_rain() -> void:
	if rain_particles == null:
		push_warning("No se encontró HeavyRain. Asigna Heavy Rain Path en el Inspector.")
		return

	rain_particles.visible = true
	rain_particles.emitting = true
	rain_particles.z_index = 1000
	rain_particles.position = Vector2(480, -80)
	rain_particles.visibility_rect = Rect2(Vector2(-2000, -2000), Vector2(5000, 5000))
	rain_particles.restart()

func setup_credits() -> void:
	for child in credits_container.get_children():
		child.queue_free()

	add_credit_label("Created by", 28)
	add_space(18)
	add_credit_label("Diego Mejía & Nitzia Covarrubias", 24)

func add_credit_label(text: String, font_size: int) -> void:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", Color.BLACK)
	label.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	credits_container.add_child(label)

func add_space(size: int) -> void:
	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(1, size)
	credits_container.add_child(spacer)

func start_final_animation() -> void:
	fade_rect.modulate.a = 1.0
	credits_panel.modulate.a = 0.0

	var ark_target_position := ark.position + Vector2(ark_travel_distance, 0)

	var fade_tween := create_tween()
	fade_tween.tween_property(fade_rect, "modulate:a", 0.0, 1.5)

	var ark_tween := create_tween()
	ark_tween.tween_property(ark, "position:x", ark_target_position.x, ark_travel_time)

	await get_tree().create_timer(0.8).timeout

	if rain_particles != null:
		rain_particles.visible = true
		rain_particles.emitting = true
		rain_particles.restart()

	var credits_tween := create_tween()
	credits_tween.tween_property(credits_panel, "modulate:a", 1.0, 1.5)

	await ark_tween.finished

	cutscene_finished = true
	print("Final terminado. La escena permanecerá abierta.")

func _unhandled_input(event: InputEvent) -> void:
	if not cutscene_finished:
		return

	if event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_cancel"):
		return_to_menu()

func return_to_menu() -> void:
	AudioManager.stop_rain()
	AudioManager.stop_music()

	if ResourceLoader.exists(menu_scene_path):
		get_tree().change_scene_to_file(menu_scene_path)
	else:
		get_tree().quit()
