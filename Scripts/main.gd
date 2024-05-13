extends Node3D

@export var wall_scene: PackedScene

var wall_height = 0
var wall_init = false
var start_pos
var end_pos
var placing = false
var wallClone

var walls = []

var xr_interface: XRInterface
func _ready():
	if not FileAccess.file_exists("user://savegame.save"):
		var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
		var json_string = JSON.stringify({
			'walls': [], 
			'high_score': 0,
			'gun_spawns': [0,0],
		})
		save_game.store_line(json_string)
	else: # read
		var save_game = FileAccess.open("user://savegame.save", FileAccess.READ)
		while save_game.get_position() < save_game.get_length():
			var json = JSON.new()
			var parse_result = json.parse(save_game.get_line())
			var node_data = json.get_data()
			walls = node_data['walls']
	
	Messenger.WALL_HEIGHT.connect(change_wall)
	Messenger.SAVE_WALLS.connect(save_walls)
	Messenger.LOAD_WALLS.connect(load_walls)
	
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized Successfully!")
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		get_viewport().use_xr = true
		enable_passthrough()
	else:
		print("OpenXR not initialized, please check if your headset is connected")

func load_walls():
	'''walls = [
		{'sp': [1,3], 'ep': [4,6], 'height': 10}
	]'''
	for wall in walls:
		start_pos = Vector3(wall.sp[0], 0, wall.sp[1])
		end_pos = Vector3(wall.ep[0], 0, wall.ep[1])
		wallClone = wall_scene.instantiate() # create a wall
		add_child(wallClone) # add to the main scene
		wallClone.visible = true
		wallClone.get_node("MeshInstance3D").mesh.size.z = (end_pos - start_pos).length()
		wallClone.get_node("CollisionShape3D").shape.size.z = (end_pos - start_pos).length()
		wallClone.position = (end_pos - start_pos)/2 + start_pos
		wallClone.position.y = 0.025
		wallClone.rotation.y = atan((end_pos - start_pos).x/(end_pos - start_pos).z)
		wallClone.get_node("MeshInstance3D").mesh.size.y = wall.height
		wallClone.get_node("CollisionShape3D").shape.size.y = wall.height
		wallClone.position.y = wall.height/2

func save_walls(): # this also will start the game
	var save_game = FileAccess.open("user://savegame.save", FileAccess.WRITE)
	var json_string = JSON.stringify({
		'walls': walls,
		'high_score': 0,
		'gun_spawns': [0,0],
	})
	save_game.store_line(json_string)

func change_wall(height):
	wall_height = height
	wall_init = true

func _on_xr_tools_interactable_area_pointer_event(event):
	#https://github.com/GodotVR/godot-xr-tools/blob/master/addons/godot-xr-tools/events/pointer_event.gd
	if wall_height != 0:
		if event.event_type == 2: # if you pull the trigger onto the floor
			wallClone = wall_scene.instantiate() # create a wall
			add_child(wallClone) # add to the main scene
			placing = true
			wallClone.visible = true
			wallClone.get_node("MeshInstance3D").mesh.size.y = 0.05
			start_pos = event.position
		if event.event_type == 3: # if you let go of the trigger
			placing = false
			wallClone.get_node("MeshInstance3D").mesh.size.y = wall_height
			wallClone.get_node("CollisionShape3D").shape.size.y = wall_height
			wallClone.position.y = wall_height/2
			walls.append({'sp': [start_pos.x, start_pos.z], 'ep': [end_pos.x, end_pos.z], 'height': wall_height})
		if event.event_type == 4: # while you drag and place the wall
			if placing:
				end_pos = event.position
				wallClone.get_node("MeshInstance3D").mesh.size.z = (end_pos - start_pos).length()
				wallClone.get_node("CollisionShape3D").shape.size.z = (end_pos - start_pos).length()
				wallClone.position = (end_pos - start_pos)/2 + start_pos
				wallClone.position.y = 0.025
				wallClone.rotation.y = atan((end_pos - start_pos).x/(end_pos - start_pos).z)


func enable_passthrough() -> bool:
	var xr_interface: XRInterface = XRServer.primary_interface
	if xr_interface and xr_interface.is_passthrough_supported():  
		print("I am supported")
		if !xr_interface.start_passthrough():
			print("Failed to start")
			return false
	else:
		print("Not supported")
		var modes = xr_interface.get_supported_environment_blend_modes()
		if xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND in modes:
			xr_interface.set_environment_blend_mode(xr_interface.XR_ENV_BLEND_MODE_ALPHA_BLEND)
		else:
			return false

	get_viewport().transparent_bg = true
	return true
