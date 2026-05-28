extends CanvasLayer

@onready var title_label: Label = $Root/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/TitleLabel
@onready var rows_container: VBoxContainer = $Root/MarginContainer/PanelContainer/MarginContainer/VBoxContainer/RowsContainer

var total_pieces: int = 13
var placed_pieces: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	update_tracker()

func set_total_pieces(value: int) -> void:
	total_pieces = value
	update_tracker()

func add_piece() -> void:
	placed_pieces += 1
	update_tracker()

func set_progress(value: int) -> void:
	placed_pieces = value
	update_tracker()

func update_tracker() -> void:
	for child in rows_container.get_children():
		child.queue_free()

	title_label.text = "Ark Progress"

	var label := Label.new()
	label.text = str(placed_pieces) + " / " + str(total_pieces)
	label.add_theme_color_override("font_color", Color("#1e3a5f"))

	rows_container.add_child(label)
