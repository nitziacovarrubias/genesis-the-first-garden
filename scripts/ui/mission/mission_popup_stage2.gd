extends CanvasLayer

@onready var root: Control = $Root
@onready var title_label: Label = $Root/TextureRect/VBoxContainer/TitleLabel
@onready var subtitle_label: Label = $Root/TextureRect/VBoxContainer/SubtitleLabel
@onready var description_label: Label = $Root/TextureRect/VBoxContainer/DescriptionLabel
@onready var objective_label: Label = $Root/TextureRect/VBoxContainer/ObjectiveLabel
@onready var items_list: VBoxContainer = $Root/TextureRect/VBoxContainer/ItemsList
@onready var continue_button: Button = $Root/TextureRect/VBoxContainer/ContinueButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.pressed.connect(close_popup)
	root.visible = false

func show_puzzle_mission() -> void:
	title_label.text = "Stage 2 - Ark Construction"
	subtitle_label.text = "Puzzle Challenge"
	description_label.text = "Place all 13 ark pieces in their correct positions to complete the structure."
	objective_label.text = "Objective:"
	continue_button.text = "Start Puzzle"

	for child in items_list.get_children():
		child.queue_free()

	root.visible = true
	get_tree().paused = true
	continue_button.grab_focus()

func close_popup() -> void:
	root.visible = false
	get_tree().paused = false

func _unhandled_input(event: InputEvent) -> void:
	if not root.visible:
		return

	if event.is_action_pressed("ui_accept"):
		close_popup()
		get_viewport().set_input_as_handled()
