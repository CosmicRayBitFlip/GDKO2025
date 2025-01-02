extends RigidBody2D

const movement_accel :float = 1200
const max_speed      :float = 600
const jump_velocity  :float = 600
const drag_constant  :float = 5

func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("left") or Input.is_action_just_released("right"):
			add_constant_central_force(Vector2.LEFT * movement_accel)
		elif Input.is_action_just_pressed("right") or Input.is_action_just_released("left"):
			add_constant_central_force(Vector2.RIGHT * movement_accel)
		elif Input.is_action_just_pressed("jump"):
			set_axis_velocity(Vector2.UP * jump_velocity)

func _integrate_forces(state:PhysicsDirectBodyState2D) -> void:
	var drag_force:Vector2 = Vector2.RIGHT * mass * linear_velocity.x * -drag_constant
	apply_central_force(drag_force)
	
	linear_velocity.x = clampf(linear_velocity.x, -max_speed, max_speed)
