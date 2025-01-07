extends RigidBody2D

@onready var jump_buffer_timer :Timer           = $JumpBufferTimer
@onready var coyote_timer      :Timer           = $CoyoteTimer
@onready var scene_root        :Node2D          = $".."
@onready var sprite            :Sprite2D        = $Sprite
@onready var death_particles   :GPUParticles2D  = $DeathParticleEmitter
@onready var floor_ray         :Area2D          = $FloorDetector
@onready var sprite_animator   :AnimationPlayer = $SpriteAnimator

const movement_accel    :float = 1200
const jump_velocity     :float = 500
const walljump_velocity :float = 750
const drag_constant     :float = 5

var jumping      :bool = false
var just_jumped  :bool = false
var on_floor     :bool = true
var can_jump     :bool = true
var facing_right :bool = true

var current_level :NodePath

func _input(event:InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("jump"):
			if can_jump:
				jumping     = true
				just_jumped = true
				jump_buffer_timer.start()
		elif Input.is_action_just_pressed("retry"):
			scene_root.reload_current_level()

func _integrate_forces(state:PhysicsDirectBodyState2D) -> void:
	if Input.is_action_pressed("left"):
		apply_central_force(Vector2.LEFT * movement_accel)
	if Input.is_action_pressed("right"):
		apply_central_force(Vector2.RIGHT * movement_accel)
	
	var facing_dir = Input.get_axis("left", "right")
	
	if facing_dir:
		facing_right = facing_dir > 0
	
	var drag_force:Vector2 = Vector2.RIGHT * mass * linear_velocity.x * -drag_constant
	if on_floor and not Input.get_axis("left", "right"):
		apply_central_force(drag_force * 3)
	else:
		apply_central_force(drag_force)
	
	if jumping:
		if just_jumped and can_jump:
			set_axis_velocity(Vector2.UP * jump_velocity)
			just_jumped = false
			can_jump = false
			on_floor = false
	
	if floor_ray.has_overlapping_bodies():
		jump_buffer_timer.stop()
		on_floor = true
		can_jump = true
		jumping = false
	elif coyote_timer.is_stopped():
		on_floor = false
		coyote_timer.start()
	
	update_animation()

func update_animation():
	var animation = ""
	if on_floor:
		if Input.get_axis("left", "right"):
			animation += "Walk"
		else:
			animation += "Idle"
	elif linear_velocity.y < 0:
		animation += "Jump"
	else:
		animation += "Fall"
	
	if facing_right:
		animation += "Right"
	else:
		animation += "Left"
	
	if animation != sprite_animator.current_animation:
		sprite_animator.play(animation)

func spawn(levelname:NodePath):
	set_deferred(&"position", scene_root.get_node(levelname).get_node("PlayerSpawn").position)

func _on_jump_buffer_timer_timeout() -> void:
	just_jumped = false

func _on_coyote_timer_timeout() -> void:
	if not floor_ray.has_overlapping_bodies():
		can_jump = false

func _on_level_loaded(levelname:NodePath) -> void:
	current_level = levelname
	spawn(current_level)

func _on_contact_with_damage_source(_body) -> void:
	sprite.hide()
	set_deferred("freeze", true)
	death_particles.restart()
	await death_particles.finished
	scene_root.call_deferred(&"reload_current_level")
	sprite.show()
	set_deferred("freeze", false)

func _on_next_level_trigger_entered(body:Node2D) -> void:
	scene_root.call_deferred(&"go_to_next_level")
