extends Node2D

@export var map_path = "res://maps/level1.png"
@export var wall_scene: PackedScene
@export var fuel_scene: PackedScene
@export var goal_scene: PackedScene
@export var bonus_scene: PackedScene
@export var player: RigidBody2D
@export var fog_map: TileMap

var scale_factor = 64

func _ready():
	scale_factor = ConfigManager.get_param("map_pixel_scale", 64)
	load_map()

func load_map():
	# Try loading as a resource first (Works in Export if imported)
	if ResourceLoader.exists(map_path):
		var texture = load(map_path)
		if texture is Texture2D:
			var image = texture.get_image()
			process_image_data(image)
		else:
			print("Map path is not a texture: ", map_path)
	elif FileAccess.file_exists(map_path):
		# Fallback for unimported files (e.g. user provided)
		var image = Image.load_from_file(map_path)
		if image:
			process_image_data(image)
		else:
			print("Failed to load map image from file: ", map_path)
	else:
		print("Map resource/file not found: ", map_path)

func process_image_data(image):
	var size = image.get_size()

	
	for x in range(size.x):
		for y in range(size.y):
			var color = image.get_pixel(x, y)
			var pos = Vector2(x, y) * scale_factor + Vector2(scale_factor/2, scale_factor/2)
			
			# Logic for colors
			if is_approx_color(color, Color.BLACK):
				spawn(wall_scene, pos)
			elif is_approx_color(color, Color(0,0,1)): # Blue
				spawn(fuel_scene, pos)
			elif is_approx_color(color, Color(1,0,0)): # Red
				spawn(goal_scene, pos)
			elif is_approx_color(color, Color(1,1,0)): # Yellow
				spawn(bonus_scene, pos)
			elif is_approx_color(color, Color(0,1,0)): # Green
				move_player(pos)
			else:
				# Random chance for bonus in empty space?
				if randf() < 0.005: # 0.5% chance per empty pixel
					spawn(bonus_scene, pos)
			
			# Setup Fog used by TileMap
			if fog_map:
				# Set a black tile at (x,y)
				# Assumption: TileSet source 0 has a tile at 0,0 that is black
				fog_map.set_cell(0, Vector2i(x,y), 0, Vector2i(0,0)) 

signal level_completed
signal notification(text)

func spawn(scene, pos):
	if scene:
		var obj = scene.instantiate()
		obj.position = pos
		call_deferred("add_child", obj)
		
		if obj.has_signal("level_completed"):
			obj.level_completed.connect(_on_level_completed)
		
		if obj.has_signal("collected"):
			obj.collected.connect(func(msg): emit_signal("notification", msg))

func _on_level_completed():

	print("Map Level Completed")
	emit_signal("level_completed")


func move_player(pos):
	if player:
		player.global_position = pos
		# Stop any physics 
		player.linear_velocity = Vector2.ZERO
		player.angular_velocity = 0

func is_approx_color(c1, c2):
	# Simple distance check
	var d = (Vector3(c1.r, c1.g, c1.b) - Vector3(c2.r, c2.g, c2.b)).length()
	return d < 0.1

func _process(delta):
	if player and fog_map:
		update_fog()

func update_fog():
	# Clear fog around player
	var p_pos = player.global_position
	# Convert to map coords
	var map_pos = fog_map.local_to_map(p_pos)
	
	var radius = 3 # Reveal radius
	for x in range(map_pos.x - radius, map_pos.x + radius + 1):
		for y in range(map_pos.y - radius, map_pos.y + radius + 1):
			if fog_map.get_cell_source_id(0, Vector2i(x,y)) != -1:
				fog_map.erase_cell(0, Vector2i(x,y))
