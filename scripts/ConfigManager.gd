extends Node

var config = {}
const CONFIG_PATH = "res://configs/game_config.json"

func _ready():
	load_config()

signal config_updated(key, value)

func load_config():
	# Load user config first if exists
	var user_path = "user://custom_config.json"
	if FileAccess.file_exists(user_path):
		var file = FileAccess.open(user_path, FileAccess.READ)
		var json = JSON.new()
		if json.parse(file.get_as_text()) == OK:
			var user_config = json.data
			config.merge(user_config, true)
			print("User config loaded override.")
			return

	if FileAccess.file_exists(CONFIG_PATH):
		var file = FileAccess.open(CONFIG_PATH, FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.new()
		var error = json.parse(json_string)
		if error == OK:
			config = json.data
			print("Config loaded successfully: ", config)
		else:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
	else:
		print("Config file not found at: ", CONFIG_PATH)
		# Fallback defaults
		config = {
			"fuel_consumption_rate": 5.0,
			"refill_amount": 50.0,
			"max_fuel": 100.0,
			"spaceship_durability": 100.0,
			"thrust_strength": 500.0,
			"rotation_torque": 2000.0,
			"map_pixel_scale": 64
		}

func get_param(key, default_value = null):
	return config.get(key, default_value)

func set_param(key, value):
	config[key] = value
	emit_signal("config_updated", key, value)
	# Auto save?
	save_user_config()

func save_user_config():
	var file = FileAccess.open("user://custom_config.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(config))

