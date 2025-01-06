extends CharacterBody2D

@onready var scene_root :Node2D = $".."

@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var walking_speed := 500
@export_custom(PROPERTY_HINT_NONE, "suffix:px/s") var jump_speed    := 500

var state_machine :PlayerState = PlayerState.new()
var input_dir     :int

var walk_easing     :float = 0.0
var jump_easing     :float = 0.0
var walljump_easing :float = 0.0

func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		input_dir = Input.get_axis("left", "right")
		state_machine.set_state_from_bool(PlayerState.WALKING, input_dir)
		
		if not state_machine.state_is_set(PlayerState.FACING_LEFT) and input_dir < 0:
			state_machine.add_state(PlayerState.FACING_LEFT)
		elif state_machine.state_is_set(PlayerState.FACING_LEFT) and input_dir > 0:
			state_machine.remove_state(PlayerState.FACING_LEFT)
		
		if Input.is_action_just_pressed("jump") and state_machine.state_is_set(PlayerState.CAN_JUMP):
			state_machine.transition_state(PlayerState.CAN_JUMP, PlayerState.JUMPING)
			jump_easing = 1.0

func _physics_process(delta:float) -> void:
	if state_machine.state_is_set(PlayerState.WALKING) and is_equal_approx(abs(walk_easing), walk_easing / input_dir):
		walk_easing += delta if not state_machine.state_is_set(PlayerState.FACING_LEFT) else -delta
	else:
		walk_easing /= 2
	
	if state_machine.state_is_set(PlayerState.JUMPING):
		jump_easing -= delta
		
		walk_easing = clampf(walk_easing, -1.0, 1.0)
		jump_easing = clampf(jump_easing, 0.0, 1.0)
		
		var walk_velocity := Vector2.RIGHT * walking_speed * walk_easing
		var jump_velocity := Vector2.UP * jump_speed * jump_easing
		
		velocity = walk_velocity + jump_velocity
		move_and_slide()

func spawn(levelname:NodePath):
	set_deferred(&"position", scene_root.get_node(levelname).get_node("PlayerSpawn").position)

func _on_level_loaded(levelname:NodePath) -> void:
	spawn(levelname)

func _on_contact_with_damage_source(_body) -> void:
	scene_root.call_deferred(&"reload_current_level")

func _on_collision_with_floor(_body) -> void:
	pass#on_floor = true

func _on_floor_left(_body) -> void:
	pass#on_floor = false

func _on_next_level_trigger_entered(body:Node2D) -> void:
	scene_root.call_deferred(&"go_to_next_level")
