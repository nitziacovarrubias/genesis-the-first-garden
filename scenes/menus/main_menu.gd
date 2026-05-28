extends Control

@export var intro_scene_path: String = "res://scenes/core/IntroDay1.tscn"
@export var credits_scene_path: String = "res://scenes/levels/FinalCutscene.tscn"

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hover_sfx: AudioStreamPlayer = $HoverSfx
@onready var click_sfx: AudioStreamPlayer = $ClickSfx
@onready var bgm: AudioStreamPlayer = $Bgm
@onready var fade: ColorRect = $Fade

var pointer_cursor = preload("res://assets/cursors/pointer.png")
var arrow_cursor = preload("res://assets/cursors/cursor.png")

func _ready() -> void:
	Input.set_custom_mouse_cursor(arrow_cursor, Input.CURSOR_ARROW, Vector2.ZERO)
	Input.set_custom_mouse_cursor(pointer_cursor, Input.CURSOR_POINTING_HAND, Vector2.ZERO)

	if bgm.stream:
		bgm.play()

	fade.modulate.a = 0.0

	if not animation_player.animation_finished.is_connected(_on_animation_finished):
		animation_player.animation_finished.connect(_on_animation_finished)

	_setup_menu_items()
	animation_player.play("menu_intro")


func _setup_menu_items() -> void:
	var items = get_tree().get_nodes_in_group("menu_items")

	for item in items:
		if item is Control:
			item.mouse_filter = Control.MOUSE_FILTER_STOP
			item.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND

			for child in item.get_children():
				if child is Control:
					child.mouse_filter = Control.MOUSE_FILTER_IGNORE

			if not item.mouse_entered.is_connected(_on_item_entered.bind(item)):
				item.mouse_entered.connect(_on_item_entered.bind(item))

			if not item.mouse_exited.is_connected(_on_item_exited.bind(item)):
				item.mouse_exited.connect(_on_item_exited.bind(item))

			if not item.gui_input.is_connected(_on_item_gui_input.bind(item)):
				item.gui_input.connect(_on_item_gui_input.bind(item))


func _on_animation_finished(anim_name: StringName) -> void:
	print("animacion terminada:", anim_name)

	match String(anim_name):
		"menu_intro":
			animation_player.play("menu_idle")


func _get_label(item: Control) -> CanvasItem:
	match item.name:
		"BtnNewGameMargin":
			return item.get_node_or_null("BtnNewGameRow/BtnNewGameLabel")
		"BtnLoadGameMargin":
			return item.get_node_or_null("BtnLoadGameRow/BtnLoadGameLabel")
		"BtnOptionsMargin":
			return item.get_node_or_null("BtnOptionsRow/BtnOptionsLabel")
		"BtnCreditsMargin":
			return item.get_node_or_null("BtnCreditsRow/BtnCreditsLabel")
		"BtnQuitMargin":
			return item.get_node_or_null("BtnQuitRow/BtnQuitLabel")

	return null


func _on_item_entered(item: Control) -> void:
	var label := _get_label(item)

	if label:
		var tween := create_tween()
		tween.tween_property(label, "modulate", Color(1.0, 0.95, 0.78, 1.0), 0.12)

	if hover_sfx.stream and not hover_sfx.playing:
		hover_sfx.play()


func _on_item_exited(item: Control) -> void:
	var label := _get_label(item)

	if label:
		var tween := create_tween()
		tween.tween_property(label, "modulate", Color(1, 1, 1, 1), 0.12)


func _on_item_gui_input(event: InputEvent, item: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if click_sfx.stream:
			click_sfx.play()

		match item.name:
			"BtnNewGameMargin":
				_on_new_game_button_pressed()

			"BtnLoadGameMargin":
				print("Load Game")

			"BtnOptionsMargin":
				print("Options")

			"BtnCreditsMargin":
				_on_credits_button_pressed()

			"BtnQuitMargin":
				get_tree().quit()


func _on_new_game_button_pressed() -> void:
	print("New Game presionado")
	change_scene_with_fade(intro_scene_path)


func _on_credits_button_pressed() -> void:
	print("Credits presionado")
	change_scene_with_fade(credits_scene_path)


func change_scene_with_fade(scene_path: String) -> void:
	if bgm.playing:
		bgm.stop()

	if animation_player.has_animation("fade_out"):
		animation_player.play("fade_out")
		print("fade_out iniciado")
		await get_tree().create_timer(0.5).timeout

	go_to_scene(scene_path)


func go_to_scene(scene_path: String) -> void:
	print("intentando cargar:", scene_path)

	var exists := ResourceLoader.exists(scene_path)
	print("existe la escena?: ", exists)

	if not exists:
		push_error("No existe la escena: " + scene_path)
		return

	var err = get_tree().change_scene_to_file(scene_path)
	print("resultado change_scene_to_file:", err)
