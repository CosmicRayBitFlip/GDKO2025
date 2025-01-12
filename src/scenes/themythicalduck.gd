extends Area2D

@onready var scene_root = $".."
@onready var collect_sfx_player :AudioStreamPlayer = $CollectSFXPlayer

var end_level_number = 10
var collected := false

func _ready() -> void:
	hide()

func _on_level_loaded(level:NodePath) -> void:
	if level == NodePath("Level" + str(end_level_number)):
		show()
		$AnimationPlayer.play("default")
	else:
		hide()
		$AnimationPlayer.play("RESET")

func _on_body_entered(body:Node2D) -> void:
	if visible and body.name == "Player":
		scene_root.get_node("Level" + str(end_level_number)).queue_free()
		$Sprite.hide()
		collect_sfx_player.play()
		var credits = preload("res://src/scenes/credits.tscn").instantiate()
		scene_root.add_child(credits)
		$DeathParticleEmitter.restart()
		if scene_root.speedrun_state == scene_root.SPEEDRUN_ACTIVE:
			scene_root.speedrun_state = scene_root.SPEEDRUN_FINISHED
		await $DeathParticleEmitter.finished
		await collect_sfx_player.finished
		queue_free()
