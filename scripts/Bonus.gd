extends Area2D

signal collected(message)

func _ready():
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):

	# Random effect
	var type = randi() % 2
	var msg = ""
	var valid = false
	
	if type == 0:
		print("Bonus Type: Fuel")
		if body.has_method("refill_fuel"):
			body.refill_fuel(30.0)
			msg = "BONUS: EXTRA FUEL (+30)"
			valid = true
	else:
		print("Bonus Type: Boost")
		if body.has_method("apply_thrust_boost"):
			body.apply_thrust_boost(1.5, 5.0)
			msg = "BONUS: SPEED BOOST (5s)"
			valid = true
	
	if valid:
		print("Bonus applied: ", msg)
		emit_signal("collected", msg)
		queue_free()

