extends Node3D

var xr_interface: XRInterface
@onready var wall_scene = load("res://wall.tscn")

var start_pos
var end_pos
var placing = false
var wallClone

func _ready():
	xr_interface = XRServer.find_interface("OpenXR")
	if xr_interface and xr_interface.is_initialized():
		print("OpenXR initialized Successfully!")
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
		
		get_viewport().use_xr = true
		#enable_passthrough()
	else:
		print("OpenXR not initialized, please check if your headset is connected")

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

func _on_xr_tools_interactable_area_pointer_event(event):
	#https://github.com/GodotVR/godot-xr-tools/blob/master/addons/godot-xr-tools/events/pointer_event.gd
	if event.event_type == 2:
		wallClone = wall_scene.instantiate()
		add_child(wallClone)
		placing = true
		wallClone.visible = true
		wallClone.get_node("MeshInstance3D").mesh.size.y = 0.05
		start_pos = event.position
	if event.event_type == 3:
		placing = false
		wallClone.get_node("MeshInstance3D").mesh.size.y = 20
		wallClone.get_node("CollisionShape3D").shape.size.y = 20
		wallClone.position.y = 10
	if event.event_type == 4:
		if placing:
			end_pos = event.position
			wallClone.get_node("MeshInstance3D").mesh.size.z = (end_pos - start_pos).length()
			wallClone.get_node("CollisionShape3D").shape.size.z = (end_pos - start_pos).length()
			wallClone.position = (end_pos - start_pos)/2 + start_pos
			wallClone.position.y = 0.025
			wallClone.rotation.y = atan((end_pos - start_pos).x/(end_pos - start_pos).z)
