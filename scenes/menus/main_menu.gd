extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var hover_sfx: AudioStreamPlayer = $HoverSfx
@onready var click_sfx: AudioStreamPlayer = $ClickSfx
@onready var bgm: AudioStreamPlayer = $Bgm
var pointer_cursor = preload("res://assets/cursors/pointer.png")
var arrow_cursor  = preload("res://assets/cursors/cursor.png")

func _ready() -> void:	
	Input.set_custom_mouse_cursor(arrow_cursor, Input.CURSOR_ARROW, Vector2.ZERO)
	
	if bgm.stream:
		bgm.play()
		
	animation_player.animation_finished.connect(_on_animation_finished)
	_setup_menu_items()
	animation_player.play("menu_intro")

func _setup_menu_items() -> void:
	var items = get_tree().get_nodes_in_group("menu_items")
	print("cantidad en menu_items: ", items.size())

	for item in items:
		print("item encontrado: ", item.name)
		if item is Control:
			item.mouse_filter = Control.MOUSE_FILTER_STOP
			item.mouse_entered.connect(_on_item_entered.bind(item))
			item.mouse_exited.connect(_on_item_exited.bind(item))
			item.gui_input.connect(_on_item_gui_input.bind(item))

func _on_animation_finished(anim_name: StringName) -> void:
	if anim_name == "menu_intro":
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
	print("hover en: ", item.name)

	Input.set_custom_mouse_cursor(pointer_cursor, Input.CURSOR_ARROW, Vector2.ZERO)

	var label := _get_label(item)
	if label:
		var tween := create_tween()
		tween.tween_property(label, "modulate", Color(1.0, 0.95, 0.78, 1.0), 0.12)

	if hover_sfx.stream and not hover_sfx.playing:
		hover_sfx.play()

func _on_item_exited(item: Control) -> void:
	print("salio de: ", item.name)

	Input.set_custom_mouse_cursor(arrow_cursor, Input.CURSOR_ARROW, Vector2.ZERO)

	var label := _get_label(item)
	if label:
		var tween := create_tween()
		tween.tween_property(label, "modulate", Color(1, 1, 1, 1), 0.12) 

func _on_item_gui_input(event: InputEvent, item: Control) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		print("click en: ", item.name)

		if click_sfx.stream:
			click_sfx.play()

		match item.name:
			"BtnNewGameMargin":
				_on_new_game_pressed()
			"BtnLoadGameMargin":
				print("Load Game")
			"BtnOptionsMargin":
				print("Options")
			"BtnCreditsMargin":
				print("Credits")
			"BtnQuitMargin":
				get_tree().quit()

func _on_new_game_pressed() -> void:
	print("comienzo de dia 1...")
	
	
