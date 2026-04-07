extends Control

@onready var animation_player: AnimationPlayer = $AnimationPlayer

@onready var intro_drone: AudioStreamPlayer = $IntroDrone
@onready var text_whoosh: AudioStreamPlayer = $TextWhoosh
@onready var divine_rise: AudioStreamPlayer = $DivineRise
@onready var light_flash_sfx: AudioStreamPlayer = $LightFlashSfx
@onready var ring_tail: AudioStreamPlayer = $RingTail
@onready var dark_swell: AudioStreamPlayer = $DarkSwell
@onready var mission_pad: AudioStreamPlayer = $MissionPad

func _ready() -> void:
	play_intro_drone()
	animation_player.play("play_intro")
	animation_player.advance(0)

func play_intro_drone() -> void:
	if intro_drone.stream:
		intro_drone.play()

func play_text_whoosh() -> void:
	if text_whoosh.stream:
		text_whoosh.play()

func play_divine_rise() -> void:
	if divine_rise.stream:
		divine_rise.play()

func play_light_flash() -> void:
	if light_flash_sfx.stream:
		light_flash_sfx.play(4)

func play_ring_tail() -> void:
	if ring_tail.stream:
		ring_tail.play()

func play_dark_swell() -> void:
	if dark_swell.stream:
		dark_swell.play()

func play_mission_pad() -> void:
	if mission_pad.stream:
		mission_pad.play()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "play_intro":
		get_tree().change_scene_to_file("res://scenes/levels/Day1.tscn")
