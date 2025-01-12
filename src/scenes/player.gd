extends RigidBody2D

@onready var scene_root         :Node2D            = $".."
@onready var jump_buffer_timer  :Timer             = $JumpBufferTimer
@onready var coyote_timer       :Timer             = $CoyoteTimer
@onready var sprite             :Sprite2D          = $Sprite
@onready var death_particles    :GPUParticles2D    = $DeathParticleEmitter
@onready var floor_ray          :Area2D            = $FloorDetector
@onready var sprite_animator    :AnimationPlayer   = $SpriteAnimator
@onready var sfx_player         :AudioStreamPlayer = $SFXPlayer
@onready var next_level_sfx_plr :AudioStreamPlayer = $NextLevelSFXPlayer

@onready var jump_sound       :AudioStream = preload("res://assets/sfx/jump.wav")
@onready var death_sound      :AudioStream = preload("res://assets/sfx/death.wav")
@onready var next_level_sound :AudioStream = preload("res://assets/sfx/nextlevel.wav")

const movement_accel    :float = 1400
const jump_velocity     :float = 500
const walljump_velocity :float = 750
const drag_constant     :float = 5

var jumping       :bool = false
var just_jumped   :bool = false
var jump_buffered :bool = false
var on_floor      :bool = true
var can_jump      :bool = true
var facing_right  :bool = true

var current_level :NodePath

func _unhandled_input(event:InputEvent) -> void:
	if event is InputEventKey:
		if Input.is_action_just_pressed("jump"):
			if linear_velocity.y >= 50:
				jump_buffered = true
				jump_buffer_timer.start()
			elif not jumping:
				just_jumped = true
		elif Input.is_action_just_pressed("retry"):
			scene_root.reload_current_level()

func _integrate_forces(state:PhysicsDirectBodyState2D) -> void:
	if Input.is_action_pressed("left"):
		apply_central_force(Vector2.LEFT * movement_accel)
	if Input.is_action_pressed("right"):
		apply_central_force(Vector2.RIGHT * movement_accel)
	
	if Input.is_action_pressed("jump"):
		gravity_scale = 1
	else:
		gravity_scale = 1.65 # maybe add a quick-fall?
	
	var facing_dir = Input.get_axis("left", "right")
	
	if facing_dir:
		facing_right = facing_dir > 0
	
	var drag_force:Vector2 = Vector2.RIGHT * mass * linear_velocity.x * -drag_constant
	if on_floor and not Input.get_axis("left", "right"):
		apply_central_force(drag_force * 3)
	else:
		apply_central_force(drag_force)
	
	if not on_floor and linear_velocity.y > 0 and just_jumped:
		just_jumped = false
	
	if floor_ray.has_overlapping_bodies() and linear_velocity.y >= -50 and not just_jumped:
		on_floor = true
		can_jump = true
		jumping = false
	elif coyote_timer.is_stopped():
		on_floor = false
		coyote_timer.start()
	
	if (just_jumped or jump_buffered) and can_jump and not jumping:
		sfx_player.stream = jump_sound
		sfx_player.play()
		jump_buffer_timer.stop()
		set_axis_velocity(Vector2.UP * jump_velocity)

		jumping = true
		just_jumped = false
		jump_buffered = false
		can_jump = false
		on_floor = false
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
	jump_buffered = false

func _on_coyote_timer_timeout() -> void:
	if not floor_ray.has_overlapping_bodies():
		can_jump = false

func _on_level_loaded(levelname:NodePath) -> void:
	current_level = levelname
	spawn(current_level)

func _on_contact_with_damage_source(_body) -> void:
	sprite.hide()
	sfx_player.stream = death_sound
	sfx_player.play()
	set_deferred("freeze", true)
	death_particles.restart()
	scene_root.music_player.volume_db = -50
	await death_particles.finished
	var tween = scene_root.music_player.create_tween()
	tween.tween_property(scene_root.music_player, "volume_db", 0, 0.5)
	scene_root.call_deferred(&"reload_current_level")
	sprite.show()
	set_deferred("freeze", false)

func _on_next_level_trigger_entered(body:Node2D) -> void:
	next_level_sfx_plr.play()
	on_floor = true
	scene_root.call_deferred(&"go_to_next_level")
# 
func _on_speedrun_mode_trigger_entered(body:Node2D) -> void:
	scene_root.speedrun_state = scene_root.SPEEDRUN_ACTIVE
	scene_root.music_player.stream = preload("res://assets/mus/kevmacleoddoubleo.mp3")
	scene_root.music_player.play()
	
	_on_next_level_trigger_entered(body)
