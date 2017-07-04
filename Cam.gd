extends Node2D

func _process(delta):
	if(Input.is_key_pressed(KEY_D)):
		set_global_pos(get_global_pos() + Vector2(10, 0) * get_node("Camera2D").get_zoom())
	elif(Input.is_key_pressed(KEY_A)):
		set_global_pos(get_global_pos() + Vector2(-10, 0) * get_node("Camera2D").get_zoom())
	if(Input.is_key_pressed(KEY_W)):
		set_global_pos(get_global_pos() + Vector2(0, -10) * get_node("Camera2D").get_zoom())
	elif(Input.is_key_pressed(KEY_S)):
		set_global_pos(get_global_pos() + Vector2(0, 10) * get_node("Camera2D").get_zoom())
	if(Input.is_key_pressed(KEY_X)):
		get_node("Camera2D").set_zoom(get_node("Camera2D").get_zoom() * 1.1)
	if(Input.is_key_pressed(KEY_Z)):
		get_node("Camera2D").set_zoom(get_node("Camera2D").get_zoom() * 0.9)

func _ready():
	set_process(true)
