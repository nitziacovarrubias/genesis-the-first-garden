extends Node

const BACKGROUND_MUSIC := "res://assets/audio/music/background_music.mp3"
const FINAL_MUSIC := "res://assets/audio/music/final_music.mp3"

const COLLECT_SFX := "res://assets/audio/sfx/collect_item.mp3"
const FALL_SFX := "res://assets/audio/sfx/fall.mp3"
const POKEBALL_THROW_SFX := "res://assets/audio/sfx/pokeball_throw.mp3"

const RAIN_LOOP := "res://assets/audio/ambience/rain_loop.mp3"

var music_player: AudioStreamPlayer
var rain_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

var current_music_path := ""
var current_rain_path := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	music_player = AudioStreamPlayer.new()
	music_player.name = "MusicPlayer"
	add_child(music_player)
	music_player.finished.connect(_on_music_finished)

	rain_player = AudioStreamPlayer.new()
	rain_player.name = "RainPlayer"
	add_child(rain_player)
	rain_player.finished.connect(_on_rain_finished)

	for i in range(10):
		var sfx_player := AudioStreamPlayer.new()
		sfx_player.name = "SFXPlayer_" + str(i)
		add_child(sfx_player)
		sfx_players.append(sfx_player)


func play_background_music() -> void:
	play_music(BACKGROUND_MUSIC, -14.0)


func play_final_music() -> void:
	play_music(FINAL_MUSIC, -12.0)


func play_music(path: String, volume_db: float = -10.0) -> void:
	if current_music_path == path and music_player.playing:
		return

	var stream := load(path)

	if stream == null:
		push_warning("No se encontró la música: " + path)
		return

	current_music_path = path
	music_player.stream = stream
	music_player.volume_db = volume_db
	music_player.play()


func stop_music() -> void:
	current_music_path = ""
	music_player.stop()


func play_collect() -> void:
	# Cambia 0.45 si quieres que dure más o menos
	play_sfx(COLLECT_SFX, -4.0, 0.45)


func play_fall() -> void:
	# Sonido de caída un poco más largo
	play_sfx(FALL_SFX, -2.0, 0.75)


func play_pokeball_throw() -> void:
	# Sonido corto al lanzar con E
	play_sfx(POKEBALL_THROW_SFX, -3.0, 0.55)


func play_sfx(path: String, volume_db: float = 0.0, max_duration: float = 0.0) -> void:
	var stream := load(path)

	if stream == null:
		push_warning("No se encontró el sonido: " + path)
		return

	var available_player := get_available_sfx_player()
	var token := str(Time.get_ticks_msec()) + "_" + str(randi())

	available_player.set_meta("sfx_token", token)
	available_player.stream = stream
	available_player.volume_db = volume_db
	available_player.play()

	if max_duration > 0.0:
		_stop_sfx_after_time(available_player, token, max_duration)


func _stop_sfx_after_time(player: AudioStreamPlayer, token: String, duration: float) -> void:
	await get_tree().create_timer(duration).timeout

	if player == null:
		return

	if not is_instance_valid(player):
		return

	if not player.has_meta("sfx_token"):
		return

	if player.get_meta("sfx_token") != token:
		return

	if player.playing:
		player.stop()


func get_available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player

	var extra_player := AudioStreamPlayer.new()
	extra_player.name = "SFXPlayer_Extra"
	add_child(extra_player)
	sfx_players.append(extra_player)

	return extra_player


func play_rain(volume_db: float = -15.0) -> void:
	if current_rain_path == RAIN_LOOP and rain_player.playing:
		return

	var stream := load(RAIN_LOOP)

	if stream == null:
		push_warning("No se encontró el sonido de lluvia: " + RAIN_LOOP)
		return

	current_rain_path = RAIN_LOOP
	rain_player.stream = stream
	rain_player.volume_db = volume_db
	rain_player.play()


func stop_rain() -> void:
	current_rain_path = ""
	rain_player.stop()


func _on_music_finished() -> void:
	if current_music_path != "":
		music_player.play()


func _on_rain_finished() -> void:
	if current_rain_path != "":
		rain_player.play()
