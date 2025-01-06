extends Area2D

@onready var scene_root = $".."
var end_level_number = 10

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
		var credits = preload("res://src/scenes/credits.tscn").instantiate()
		scene_root.add_child(credits)
		$DeathParticleEmitter.restart()
		await $DeathParticleEmitter.finished
		queue_free()
