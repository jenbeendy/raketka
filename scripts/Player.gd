extends RigidBody2D

signal fuel_changed(current_fuel, max_fuel)
signal health_changed(current_health, max_health)
signal crashed

var max_fuel = 100.0
var current_fuel = 100.0
var fuel_consumption = 5.0
var thrust_strength = 500.0
var rotation_torque = 2000.0
var max_durability = 100.0
var durability = 100.0


@onready var main_thruster_vis = $ShipVisuals/MainThruster
@onready var left_thruster_vis = $ShipVisuals/LeftThruster
@onready var right_thruster_vis = $ShipVisuals/RightThruster
@onready var thruster_sound = $ThrusterSound
@onready var crash_sound = $CrashSound # Will fail if node not exists, handled in Tscn update

func _ready():
	config_init() # Helper to keep code clean or just inline
	# Load configs
	fuel_consumption = ConfigManager.get_param("fuel_consumption_rate", 5.0)
	max_fuel = ConfigManager.get_param("max_fuel", 100.0)
	thrust_strength = ConfigManager.get_param("thrust_strength", 500.0)
	rotation_torque = ConfigManager.get_param("rotation_torque", 2000.0)
	max_durability = ConfigManager.get_param("spaceship_durability", 100.0)
	durability = max_durability
	
	current_fuel = max_fuel
	emit_signal("fuel_changed", current_fuel, max_fuel)
	emit_signal("health_changed", durability, max_durability)
	
	emit_signal("health_changed", durability, max_durability)
	
	body_entered.connect(_on_body_entered)
	
	ConfigManager.config_updated.connect(_on_config_updated)

func _on_config_updated(key, value):
	match key:
		"thrust_strength": thrust_strength = value
		"rotation_torque": rotation_torque = value
		"fuel_consumption_rate": fuel_consumption = value
		"spaceship_durability": 
			# Assuming change applies to next run or max?
			max_durability = value
			emit_signal("health_changed", durability, max_durability)
		"max_fuel":
			max_fuel = value
			emit_signal("fuel_changed", current_fuel, max_fuel)

func config_init():

	pass

func _physics_process(delta):
	var is_thrusting = false
	var is_rotating_left = false
	var is_rotating_right = false
	
	if current_fuel > 0:
		# Translation (Up relative to ship)
		# Godot 2D: Up is (0, -1). Rotated by rotation.
		# But RigidBody apply_central_force is in global coordinates usually, 
		# or utilize local basis.
		
		# Move Forward (Up arrow) -> Fire Bottom Thruster -> Force Upwards relative to ship
		if Input.is_action_pressed("ui_up") or Input.is_action_pressed("ui_accept"): # W is often mapped to ui_up or we accept defaults
			# Apply force in the direction the ship is facing (Vector2.UP rotated)
			var force_dir = Vector2.UP.rotated(rotation)
			apply_central_force(force_dir * thrust_strength)
			current_fuel -= fuel_consumption * delta
			is_thrusting = true
		
		# Rotation
		# Left Arrow (ui_left) -> Rotate Counter-Clockwise -> Fire Right Thruster
		if Input.is_action_pressed("ui_left"):
			apply_torque(-rotation_torque)
			current_fuel -= fuel_consumption * 0.5 * delta
			is_rotating_left = true
			
		# Right Arrow (ui_right) -> Rotate Clockwise -> Fire Left Thruster
		if Input.is_action_pressed("ui_right"):
			apply_torque(rotation_torque)
			current_fuel -= fuel_consumption * 0.5 * delta
			is_rotating_right = true
	
	# clamp fuel
	current_fuel = max(0, current_fuel)
	emit_signal("fuel_changed", current_fuel, max_fuel)
	
	update_visuals(is_thrusting, is_rotating_left, is_rotating_right)
	
	if is_thrusting or is_rotating_left or is_rotating_right:
		if thruster_sound and not thruster_sound.playing:
			thruster_sound.play()
	else:
		if thruster_sound:
			thruster_sound.stop()


func update_visuals(main, left, right):
	if main_thruster_vis: main_thruster_vis.visible = main
	# To turn Left (CCW), we fire the Right thruster
	if right_thruster_vis: right_thruster_vis.visible = left 
	# To turn Right (CW), we fire the Left thruster
	if left_thruster_vis: left_thruster_vis.visible = right

func refill_fuel(amount):
	current_fuel = min(current_fuel + amount, max_fuel)
	emit_signal("fuel_changed", current_fuel, max_fuel)



func _on_body_entered(body):
	print("Body entered: ", body.name)
	# Calculate impact speed (approximation)
	# For accurate impact impulse, we'd need _integrate_forces, but velocity on impact is close enough
	var speed = linear_velocity.length()
	var crash_threshold = 100.0
	
	if speed > crash_threshold:
		if crash_sound:
			crash_sound.play()
			
		# Calculate damage
		# e.g. 10 damage per 100 speed units roughly
		var damage = (speed - 50.0) * 0.2
		take_damage(damage)
		
		# Bounce effect is inherent to PhysicsMaterial, 
		# but we can add extra "shock" if needed, though RigidBody handles it.

func take_damage(amount):
	print("Taking damage: ", amount)
	durability -= amount
	emit_signal("health_changed", durability, max_durability)
	
	if durability <= 0:
		die()

func die():
	print("Game Over")
	emit_signal("crashed")
	set_physics_process(false)
	# stop movement
	sleeping = true
	# Optional: Explosion effect


func apply_thrust_boost(multiplier, duration):
	thrust_strength *= multiplier
	# clear any existing timer?
	await get_tree().create_timer(duration).timeout
	thrust_strength /= multiplier

