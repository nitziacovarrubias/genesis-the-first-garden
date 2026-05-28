extends Node

signal mission_updated(biome_id: String)
signal mission_completed(biome_id: String)

var missions := {
	"spring": {
		"title": "First Mission",
		"subtitle": "The Ark Begins",
		"description": "Collect natural resources to begin building the Ark.",
		"items": {
			"wood": {
				"display_name": "Wood",
				"required": 10,
				"icon": preload("res://assets/sprites/items/spring/wood.png")
			},
			"rope": {
				"display_name": "Rope",
				"required": 4,
				"icon": preload("res://assets/sprites/items/spring/rope.png")
			},
			"pitch": {
				"display_name": "Pitch",
				"required": 3,
				"icon": preload("res://assets/sprites/items/spring/pitch.png")
			},
			"stone": {
				"display_name": "Stone",
				"required": 5,
				"icon": preload("res://assets/sprites/items/spring/stone.png")
			}
		}
	},
	"summer": {
		"title": "Second Mission",
		"subtitle": "Gather the Animal Pairs",
		"description": "Noah must gather seven animal pairs before moving forward.",
		"list_format": "pairs_short",
		"pair_order": [
			"cow",
			"horse",
			"pig",
			"goat",
			"donkey",
			"duck",
			"chicken"
		],
		"pair_names": {
			"cow": "Cows",
			"horse": "Horses",
			"pig": "Pigs",
			"goat": "Goats",
			"donkey": "Donkeys",
			"duck": "Ducks",
			"chicken": "Chickens"
		},
		"items": {
			"cow_female": {
				"display_name": "Cow Female",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/cow_female.tres")
			},
			"cow_male": {
				"display_name": "Cow Male",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/cow_male.tres")
			},

			"horse_female": {
				"display_name": "Horse Female",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/horse_female.tres")
			},
			"horse_male": {
				"display_name": "Horse Male",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/horse_male.tres")
			},

			"pig_female": {
				"display_name": "Pig Female",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/pig_female.tres")
			},
			"pig_male": {
				"display_name": "Pig Male",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/pig_male.tres")
			},

			"goat_female": {
				"display_name": "Goat Female",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/goat_female.tres")
			},
			"goat_male": {
				"display_name": "Goat Male",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/goat_male.tres")
			},

			"donkey_female": {
				"display_name": "Donkey Female",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/donkey_female.tres")
			},
			"donkey_male": {
				"display_name": "Donkey Male",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/donkey_male.tres")
			},

			"duck_female": {
				"display_name": "Duck Female",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/duck_female.tres")
			},
			"duck_male": {
				"display_name": "Duck Male",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/duck_male.tres")
			},

			"chicken_female": {
				"display_name": "Chicken Female",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/chicken_female.tres")
			},
			"chicken_male": {
				"display_name": "Chicken Male",
				"required": 1,
				"icon": preload("res://assets/sprites/animals/summer/atlas/chicken_male.tres")
			}
		}
	},
	"winter": {
		"title": "Winter Biome",
		"subtitle": "Gather Noah's Family",
		"description": "The storm is getting closer. Find Noah's family and bring them together before moving forward.",
		"items": {
			"noahs_wife": {
				"display_name": "Noah's Wife",
				"required": 1,
				"icon": preload("res://assets/sprites/people/winter/noahs_wife.png")
			},
			"shem": {
				"display_name": "Shem",
				"required": 1,
				"icon": preload("res://assets/sprites/people/winter/shem.png")
			},
			"ham": {
				"display_name": "Ham",
				"required": 1,
				"icon": preload("res://assets/sprites/people/winter/ham.png")
			},
			"japheth": {
				"display_name": "Japheth",
				"required": 1,
				"icon": preload("res://assets/sprites/people/winter/japheth.png")
			},
			"shems_wife": {
				"display_name": "Shem's Wife",
				"required": 1,
				"icon": preload("res://assets/sprites/people/winter/shems_wife.png")
			},
			"hams_wife": {
				"display_name": "Ham's Wife",
				"required": 1,
				"icon": preload("res://assets/sprites/people/winter/hams_wife.png")
			},
			"japheths_wife": {
				"display_name": "Japheth's Wife",
				"required": 1,
				"icon": preload("res://assets/sprites/people/winter/japheths_wife.png")
			}
		}
	}
}

var progress := {}
var completed_missions := {}

func _ready() -> void:
	initialize_missions()

func initialize_missions() -> void:
	for biome_id in missions.keys():
		progress[biome_id] = {}
		completed_missions[biome_id] = false

		var items: Dictionary = missions[biome_id]["items"]

		for item_id in items.keys():
			progress[biome_id][item_id] = 0

func add_item(biome_id: String, item_id: String, amount: int = 1) -> bool:
	if not missions.has(biome_id):
		print("Biome does not exist: ", biome_id)
		return false

	var items: Dictionary = missions[biome_id]["items"]

	if not items.has(item_id):
		print("Item does not exist in this biome: ", item_id)
		return false

	var required_amount: int = items[item_id]["required"]
	var current_amount: int = progress[biome_id].get(item_id, 0)

	if current_amount >= required_amount:
		return false

	progress[biome_id][item_id] = min(current_amount + amount, required_amount)

	mission_updated.emit(biome_id)

	if is_mission_complete(biome_id) and completed_missions[biome_id] == false:
		completed_missions[biome_id] = true
		mission_completed.emit(biome_id)

	return true

func is_mission_complete(biome_id: String) -> bool:
	if not missions.has(biome_id):
		return false

	var items: Dictionary = missions[biome_id]["items"]

	for item_id in items.keys():
		var required_amount: int = items[item_id]["required"]
		var current_amount: int = progress[biome_id].get(item_id, 0)

		if current_amount < required_amount:
			return false

	return true

func get_mission_data(biome_id: String) -> Dictionary:
	if not missions.has(biome_id):
		return {}

	return missions[biome_id]

func get_item_progress(biome_id: String, item_id: String) -> int:
	if not progress.has(biome_id):
		return 0

	return progress[biome_id].get(item_id, 0)

func get_item_required_amount(biome_id: String, item_id: String) -> int:
	if not missions.has(biome_id):
		return 0

	var items: Dictionary = missions[biome_id]["items"]

	if not items.has(item_id):
		return 0

	return items[item_id]["required"]

func get_item_display_name(biome_id: String, item_id: String) -> String:
	if not missions.has(biome_id):
		return item_id

	var items: Dictionary = missions[biome_id]["items"]

	if not items.has(item_id):
		return item_id

	return items[item_id]["display_name"]
	

func get_item_icon(biome_id: String, item_id: String) -> Texture2D:
	if not missions.has(biome_id):
		return null

	var items: Dictionary = missions[biome_id]["items"]

	if not items.has(item_id):
		return null

	return items[item_id].get("icon", null)


func get_short_mission_rows(biome_id: String) -> Array[Dictionary]:
	if not missions.has(biome_id):
		return []

	var mission_data: Dictionary = missions[biome_id]
	var items: Dictionary = mission_data["items"]

	if mission_data.get("list_format", "") == "pairs_short":
		return _get_pair_short_rows(biome_id)

	return _get_single_short_rows(biome_id)


func _get_pair_short_rows(biome_id: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []

	var mission_data: Dictionary = missions[biome_id]
	var items: Dictionary = mission_data["items"]
	var pair_order: Array = mission_data.get("pair_order", [])

	for base_id_raw in pair_order:
		var base_id := String(base_id_raw)

		var female_id := base_id + "_female"
		var male_id := base_id + "_male"

		if not items.has(female_id) or not items.has(male_id):
			continue

		rows.append({
			"type": "pair",
			"base_id": base_id,
			"display_name": _get_pair_display_name(biome_id, base_id),

			"female_id": female_id,
			"female_icon": get_item_icon(biome_id, female_id),
			"female_progress": get_item_progress(biome_id, female_id),
			"female_required": get_item_required_amount(biome_id, female_id),

			"male_id": male_id,
			"male_icon": get_item_icon(biome_id, male_id),
			"male_progress": get_item_progress(biome_id, male_id),
			"male_required": get_item_required_amount(biome_id, male_id)
		})

	return rows


func _get_single_short_rows(biome_id: String) -> Array[Dictionary]:
	var rows: Array[Dictionary] = []

	var items: Dictionary = missions[biome_id]["items"]
	var item_keys := items.keys()
	item_keys.sort()

	for raw_item_id in item_keys:
		var item_id := String(raw_item_id)

		rows.append({
			"type": "single",
			"item_id": item_id,
			"display_name": get_item_display_name(biome_id, item_id),
			"icon": get_item_icon(biome_id, item_id),
			"progress": get_item_progress(biome_id, item_id),
			"required": get_item_required_amount(biome_id, item_id)
		})

	return rows


func _get_pair_display_name(biome_id: String, base_id: String) -> String:
	if not missions.has(biome_id):
		return base_id.capitalize()

	var mission_data: Dictionary = missions[biome_id]
	var pair_names: Dictionary = mission_data.get("pair_names", {})

	if pair_names.has(base_id):
		return pair_names[base_id]

	return base_id.replace("_", " ").capitalize()
