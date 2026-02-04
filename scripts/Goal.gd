extends Area2D

signal level_completed

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	if body.name == "Player":
		print("Level Finished!")
		emit_signal("level_completed")

