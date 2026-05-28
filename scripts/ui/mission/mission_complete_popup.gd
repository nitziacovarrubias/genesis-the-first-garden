extends CanvasLayer

@onready var root: Control = $Root
@onready var title_label: Label = $Root/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var message_label: Label = $Root/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MessageLabel
@onready var continue_button: Button = $Root/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	continue_button.pressed.connect(close_popup)
	MissionManager.mission_completed.connect(show_completion)

	root.visible = false

func show_completion(biome_id: String) -> void:
	var mission_data := MissionManager.get_mission_data(biome_id)

	if mission_data.is_empty():
		return

	title_label.text = mission_data["title"] + " Completed"

	if biome_id == "spring":
		message_label.text = "All required resources have been collected.\n\nThe door at the end of the biome has been opened.\nYou may now continue."
	elif biome_id == "summer":
		message_label.text = "All seven animal pairs have been gathered.\n\nThe door at the end of the Summer Biome has been opened.\nYou may now continue."
	elif biome_id == "winter":
		message_label.text = "Noah's family has been gathered.\n\nThe door at the end of the Winter Biome has been opened.\nYou may now continue."
	else:
		message_label.text = "The mission has been completed.\n\nThe path forward is now open."

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
