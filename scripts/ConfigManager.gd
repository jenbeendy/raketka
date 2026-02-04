extends Node

var config = {}
const CONFIG_PATH = "res://configs/game_config.json"

func _ready():
	load_config()

func load_config():
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
