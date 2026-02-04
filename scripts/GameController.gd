extends Node2D

@onready var player = $Player
@onready var hud = $HUD
@onready var map_loader = $MapLoader

func _ready():
	if player and hud:
		player.fuel_changed.connect(hud.update_fuel)
		player.health_changed.connect(hud.update_health)
		player.crashed.connect(func(): hud.show_game_over(true))
		
		# Initial update
		hud.update_fuel(player.current_fuel, player.max_fuel)
		hud.update_health(player.durability, player.max_durability)
	
	if map_loader:
		map_loader.level_completed.connect(func(): hud.show_game_over(false))
		map_loader.notification.connect(hud.show_notification)


func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		if hud:
			hud.show_pause()


