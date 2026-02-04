extends CanvasLayer

@onready var fuel_bar = $Control/MarginContainer/VBoxContainer/FuelBar
@onready var health_bar = $Control/MarginContainer/VBoxContainer/HealthBar
@onready var game_over_menu = $Control/GameOverMenu
@onready var message_label = $Control/GameOverMenu/PanelContainer/VBoxContainer/MessageLabel
@onready var restart_button = $Control/GameOverMenu/PanelContainer/VBoxContainer/RestartButton

@onready var game_over_panel = $Control/GameOverMenu/PanelContainer
@onready var settings_panel = $Control/GameOverMenu/SettingsPanel
@onready var settings_button = $Control/GameOverMenu/PanelContainer/VBoxContainer/SettingsButton
@onready var close_settings_button = $Control/GameOverMenu/SettingsPanel/VBoxContainer/CloseSettingsButton

@onready var thrust_slider = $Control/GameOverMenu/SettingsPanel/VBoxContainer/GridContainer/ThrustSlider
@onready var torque_slider = $Control/GameOverMenu/SettingsPanel/VBoxContainer/GridContainer/TorqueSlider
@onready var fuel_slider = $Control/GameOverMenu/SettingsPanel/VBoxContainer/GridContainer/FuelUseSlider
@onready var durability_slider = $Control/GameOverMenu/SettingsPanel/VBoxContainer/GridContainer/DurabilitySlider

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	close_settings_button.pressed.connect(_on_close_settings_pressed)
	
	init_settings_values()
	
	# Connect Sliders
	thrust_slider.value_changed.connect(func(v): ConfigManager.set_param("thrust_strength", v))
	torque_slider.value_changed.connect(func(v): ConfigManager.set_param("rotation_torque", v))
	fuel_slider.value_changed.connect(func(v): ConfigManager.set_param("fuel_consumption_rate", v))
	durability_slider.value_changed.connect(func(v): ConfigManager.set_param("spaceship_durability", v))
	
	game_over_menu.visible = false
	
	# Set bar colors (quick and dirty via modulation)
	fuel_bar.modulate = Color(0, 0.5, 1) # Blue
	health_bar.modulate = Color(1, 0.2, 0.2) # Red

func init_settings_values():
	thrust_slider.value = ConfigManager.get_param("thrust_strength", 500.0)
	torque_slider.value = ConfigManager.get_param("rotation_torque", 2000.0)
	fuel_slider.value = ConfigManager.get_param("fuel_consumption_rate", 5.0)
	durability_slider.value = ConfigManager.get_param("spaceship_durability", 100.0)

func _on_settings_pressed():
	game_over_panel.visible = false
	settings_panel.visible = true

func _on_close_settings_pressed():
	settings_panel.visible = false
	game_over_panel.visible = true


func update_fuel(current, max_val):
	fuel_bar.max_value = max_val
	fuel_bar.value = current

func update_health(current, max_val):
	health_bar.max_value = max_val
	health_bar.value = current

func show_game_over(crashed=true):
	game_over_menu.visible = true
	get_tree().paused = true
	if crashed:
		message_label.text = "CRITICAL FAIL\nSHIP DESTROYED"
	else:
		message_label.text = "MISSION COMPLETE"

func show_pause():
	if game_over_menu.visible:
		# Resume
		game_over_menu.visible = false
		get_tree().paused = false
	else:
		# Pause
		game_over_menu.visible = true
		message_label.text = "PAUSED"
		get_tree().paused = true

func show_notification(text):
	var label = $Control/NotificationContainer/Label
	label.text = text
	label.modulate.a = 1.0
	
	# Create Notification Tween
	var tween = create_tween()
	tween.tween_interval(1.5)
	tween.tween_property(label, "modulate:a", 0.0, 1.0)
	tween.tween_callback(func(): label.text = "")

func _on_restart_pressed():

	get_tree().paused = false
	get_tree().reload_current_scene()
