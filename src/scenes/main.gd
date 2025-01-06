extends Node2D

signal level_loaded

@onready var current_level = 0 if name == "Main" else -1

func _ready() -> void:
	if name == "Main":
		level_loaded.emit(NodePath("Level0"))
	else:
		level_loaded.emit(NodePath("Level-1"))
	#switch_level(10)

func _input(event:InputEvent) -> void:
	if Input.is_action_just_pressed("debug_next_level"):
		go_to_next_level()
	elif Input.is_action_just_pressed("debug_prev_level"):
		go_to_previous_level()

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

func reload_current_level() -> void:
	switch_level(current_level)

func go_to_next_level() -> void:
	switch_level(current_level + 1)

func go_to_previous_level() -> void:
	switch_level(current_level - 1)
