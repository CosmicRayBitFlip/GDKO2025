extends RigidBody2D

class_name Throwable

const following_speed = 10

var mouse_inside    :bool = false
var following_mouse :bool = false

func _init() -> void:
	connect("body_entered", _on_collision)
	connect("mouse_entered", _mouse_enter)
	input_pickable = true
	contact_monitor = true
	max_contacts_reported = 1

func _integrate_forces(state:PhysicsDirectBodyState2D) -> void:
	if following_mouse:
		linear_velocity = global_position.direction_to(get_global_mouse_position()) * global_position.distance_to(get_global_mouse_position()) * following_speed

func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("grab_block") and mouse_inside:
		following_mouse = true
		gravity_scale = 0
	elif Input.is_action_just_released("grab_block"):
		following_mouse = false
		gravity_scale = 1

func _on_collision(body:Node2D):
	if body.name == "Player":
		following_mouse = false
		gravity_scale = 1
		collision_layer = 1

func _mouse_enter() -> void:
	mouse_inside = true

func _mouse_exit() -> void:
	mouse_inside = false
