extends CanvasLayer

@onready var root: Control = $Root
@onready var title_label: Label = $Root/TextureRect/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $Root/TextureRect/VBoxContainer/SubtitleLabel
@onready var description_label: Label = $Root/TextureRect/VBoxContainer/DescriptionLabel
@onready var objective_label: Label = $Root/TextureRect/VBoxContainer/ObjectiveLabel
@onready var items_list: VBoxContainer = $Root/TextureRect/VBoxContainer/ItemsList
@onready var continue_button: Button = $Root/TextureRect/VBoxContainer/ContinueButton

var current_biome_id := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	continue_button.pressed.connect(close_popup)
	MissionManager.mission_updated.connect(_on_mission_updated)

	root.visible = false

func show_mission(biome_id: String) -> void:
	current_biome_id = biome_id

	var mission_data := MissionManager.get_mission_data(biome_id)

	if mission_data.is_empty():
		return

	title_label.text = mission_data["title"]
	subtitle_label.text = mission_data["subtitle"]
	description_label.text = mission_data["description"]
	
	if biome_id == "spring":
		objective_label.text = "Required resources:"
	elif biome_id == "summer":
		objective_label.text = "Required animal pairs:"
	elif biome_id == "winter":
		objective_label.text = "Required people:"
	else:
		objective_label.text = "Required:"

	update_items_list(biome_id)

	root.visible = true
	get_tree().paused = true
	continue_button.grab_focus()

func close_popup() -> void:
	root.visible = false
	get_tree().paused = false


func update_items_list(biome_id: String) -> void:
	for child in items_list.get_children():
		child.queue_free()

	var mission_data := MissionManager.get_mission_data(biome_id)

	if mission_data.is_empty():
		return

	var rows: Array[Dictionary] = MissionManager.get_short_mission_rows(biome_id)

	for row_data in rows:
		if row_data["type"] == "pair":
			_create_pair_row(row_data)
		else:
			_create_single_row(row_data)

func _create_pair_row(row_data: Dictionary) -> void:
	var row := HBoxContainer.new()
	row.custom_minimum_size = Vector2(0, 28)
	row.alignment = BoxContainer.ALIGNMENT_BEGIN
	row.add_theme_constant_override("separation", 6)

	var name_label := Label.new()
	name_label.text = "- " + row_data["display_name"] + ":"
	name_label.custom_minimum_size = Vector2(100, 0)
	name_label.add_theme_color_override("font_color", Color("#1e3a5f"))

	var female_icon := TextureRect.new()
	female_icon.custom_minimum_size = Vector2(24, 24)
	female_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	female_icon.texture = row_data["female_icon"]

	var female_label := Label.new()
	female_label.text = str(row_data["female_progress"]) + "/" + str(row_data["female_required"])
	female_label.add_theme_color_override("font_color", Color("#1e3a5f"))

	var male_icon := TextureRect.new()
	male_icon.custom_minimum_size = Vector2(24, 24)
	male_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	male_icon.texture = row_data["male_icon"]

	var male_label := Label.new()
	male_label.text = str(row_data["male_progress"]) + "/" + str(row_data["male_required"])
	male_label.add_theme_color_override("font_color", Color("#1e3a5f"))

	row.add_child(name_label)
	row.add_child(female_icon)
	row.add_child(female_label)
	row.add_child(male_icon)
	row.add_child(male_label)

	items_list.add_child(row)

func _create_single_row(row_data: Dictionary) -> void:
	var label := Label.new()

	label.text = "- " + row_data["display_name"] + " " + str(row_data["progress"]) + "/" + str(row_data["required"])

	label.add_theme_color_override(
		"font_color",
		Color("#1e3a5f")
	)

	items_list.add_child(label)

func _on_mission_updated(biome_id: String) -> void:
	if root.visible and biome_id == current_biome_id:
		update_items_list(biome_id)
		
func _unhandled_input(event: InputEvent) -> void:
	if not root.visible:
		return

	if event.is_action_pressed("ui_accept"):
		close_popup()
		get_viewport().set_input_as_handled()
