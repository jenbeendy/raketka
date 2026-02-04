extends CanvasLayer

@onready var fuel_bar = $Control/MarginContainer/VBoxContainer/FuelBar
@onready var health_bar = $Control/MarginContainer/VBoxContainer/HealthBar
@onready var game_over_menu = $Control/GameOverMenu
@onready var message_label = $Control/GameOverMenu/PanelContainer/VBoxContainer/MessageLabel
@onready var restart_button = $Control/GameOverMenu/PanelContainer/VBoxContainer/RestartButton

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS
	restart_button.pressed.connect(_on_restart_pressed)
	game_over_menu.visible = false
	
	# Set bar colors (quick and dirty via modulation)
	fuel_bar.modulate = Color(0, 0.5, 1) # Blue
	health_bar.modulate = Color(1, 0.2, 0.2) # Red

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
