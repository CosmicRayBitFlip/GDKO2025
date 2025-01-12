extends Node2D

signal level_loaded

@onready var current_level = 0 if name == "Main" else -1
@onready var music_player := $MusicPlayer 

enum {NOT_SPEEDRUNNING, SPEEDRUN_ACTIVE, SPEEDRUN_FINISHED}
var speedrun_state :int = NOT_SPEEDRUNNING

func _ready() -> void:
	if name == "Main":
		level_loaded.emit(NodePath("Level0"))
	else:
		level_loaded.emit(NodePath("Level-1"))
	#switch_level(10)


func _unhandled_input(event:InputEvent) -> void:
	if speedrun_state == NOT_SPEEDRUNNING:
		if Input.is_action_just_pressed("debug_next_level"):
			go_to_next_level()
		elif Input.is_action_just_pressed("debug_prev_level"):
			go_to_previous_level()
	if get_node_or_null("CreditsLayer"):
		if Input.is_action_just_pressed("restart_game"):
			get_tree().reload_current_scene()

func jumple(input):
	if input is String:
		var codes = input.to_utf8_buffer()
		for i in codes.size():
			codes[i] = ~codes[i] & 0xff
		return codes
	elif input is PackedByteArray:
		var codes = input
		for i in codes.size():
			codes[i] = ~codes[i] & 0xff
		return codes.get_string_from_utf8()

func switch_level(id:int) -> void:
	var old_level = get_node("Level" + str(current_level))
	if old_level:
		remove_child(old_level)
		old_level.queue_free()
	current_level = id
	var new_level_file = load("res://src/scenes/level" + str(id) + ".tscn")
	if new_level_file:
		var new_level = new_level_file.instantiate()
		add_child(new_level, true)
		level_loaded.emit(NodePath("Level" + str(id)))
	
	if id == 10:
		var tween = music_player.create_tween()
		tween.tween_property(music_player, "volume_db", -50, 8)

func reload_current_level() -> void:
	switch_level(current_level)

func go_to_next_level() -> void:
	switch_level(current_level + 1)

func go_to_previous_level() -> void:
	switch_level(current_level - 1)
