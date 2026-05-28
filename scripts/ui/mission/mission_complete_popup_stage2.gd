extends CanvasLayer

signal continue_requested

@onready var root: Control = $Root
@onready var title_label: Label = $Root/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var message_label: Label = $Root/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/MessageLabel
@onready var continue_button: Button = $Root/CenterContainer/PanelContainer/MarginContainer/VBoxContainer/ContinueButton

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	continue_button.pressed.connect(_on_continue_pressed)
	root.visible = false

func show_puzzle_complete() -> void:
	title_label.text = "Mission Completed"
	message_label.text = "The Ark has been fully assembled.\n\nYou may now continue."
	continue_button.text = "Continue"

	root.visible = true
	get_tree().paused = true
	continue_button.grab_focus()

func _on_continue_pressed() -> void:
	root.visible = false
	get_tree().paused = false
	emit_signal("continue_requested")

func _unhandled_input(event: InputEvent) -> void:
	if not root.visible:
		return

	if event.is_action_pressed("ui_accept"):
		_on_continue_pressed()
		get_viewport().set_input_as_handled()
