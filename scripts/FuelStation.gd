extends Area2D

@export var refill_amount = 50.0

func _ready():
	refill_amount = ConfigManager.get_param("refill_amount", 50.0)
	body_entered.connect(_on_body_entered)
	ConfigManager.config_updated.connect(func(k,v): if k=="refill_amount": refill_amount = v)



func _process(delta):
	for body in get_overlapping_bodies():
		if body.has_method("refill_fuel"):
			# Refill rate per second? "refill_amount" was usually instant.
			# Let's treat refill_amount as "per second" now to smooth it out
			body.refill_fuel(refill_amount * delta)

func _on_body_entered(body):
	# Sound trigger only?
	if body.has_method("refill_fuel"):
		print("Entered Fuel Station")

