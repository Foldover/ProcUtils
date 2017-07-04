extends Node2D

var map
const width = 400
const height = 400
const tileSize = 1
const zoom = 1

var mouseP

func CreateMap():
	#ProcUtil.PerlinMap(map, width, height, mouseP.x, mouseP.y, 2, 0.1, 0.1, zoom)
	#ProcUtil.NormalizeMap(map, width, height)
	map = ProcUtil.MapOne2D(width, height)
	ProcUtil.AsteroidalBombardment(map, width, height, 20, 150, 200, 0.2, 0.4, 0.5)
	ProcUtil.AsteroidalBombardment(map, width, height, 80, 25, 100, 0.2, 0.4, 0.5)
	ProcUtil.AsteroidalBombardment(map, width, height, 300, 5, 50, 0.1, 0.2, 0.5)
	ProcUtil.AsteroidalBombardment(map, width, height, 1000, 1, 10, 0.02, 0.1, 0.5)
	#update()
	var img = Image(width, height, true, Image.FORMAT_RGB)
	for x in range(width):
		for y in range(height):
			var col
			if(map[x][y] <= 0.3):
				col = Color(0.0, 0.0, 0.5)
			elif(map[x][y] <= 0.55):
				col = Color(0.2, 0.2, 1.0)
			elif(map[x][y] <= 0.6):
				col = Color(0.4, 0.4, 1.0)
			elif(map[x][y] <= 0.62):
				col = Color(0.76, 0.70, 0.50)
			elif(map[x][y] <= 0.72):
				col = Color(0.49, 0.99, 0)
			elif(map[x][y] <= 0.85):
				col = Color(0, 0.50, 0)
			elif(map[x][y] <= 0.9):
				col = Color(0.54, 0.27, 0.07)
			elif(map[x][y] <= 0.95):
				col = Color(0.66, 0.66, 0.66)
			else:
				col = Color(1.0, 1.0, 1.0)
			
			#img.put_pixel(x, y, Color(map[x][y] if map[x][y] > 0 else 0, 0, 0))
			img.put_pixel(x, y, col)
			
	var tex = ImageTexture.new()
	tex.create(width, height, Image.FORMAT_RGB)
	tex.set_data(img)
	tex.set_flags(tex.FLAG_REPEAT)
	get_node("Map").set_texture(tex)
	get_node("Map").set_region_rect(Rect2(0, 0, width*2, height*2))
	#get_node("Map").get_texture().set_flags(tex.FLAG_REPEAT)

func Erode():
	ProcUtil.HydraulicErosion(map, width, height, 1, 0.8, 0.5, 0.5, 0.1)
	print(map[0][0])
	var img = Image(width, height, true, Image.FORMAT_RGB)
	for x in range(width):
		for y in range(height):
			var col
			if(map[x][y] <= 0.3):
				col = Color(0.0, 0.0, 0.5)
			elif(map[x][y] <= 0.55):
				col = Color(0.2, 0.2, 1.0)
			elif(map[x][y] <= 0.6):
				col = Color(0.4, 0.4, 1.0)
			elif(map[x][y] <= 0.62):
				col = Color(0.76, 0.70, 0.50)
			elif(map[x][y] <= 0.72):
				col = Color(0.49, 0.99, 0)
			elif(map[x][y] <= 0.85):
				col = Color(0, 0.50, 0)
			elif(map[x][y] <= 0.9):
				col = Color(0.54, 0.27, 0.07)
			elif(map[x][y] <= 0.95):
				col = Color(0.66, 0.66, 0.66)
			else:
				col = Color(1.0, 1.0, 1.0)
			
			#img.put_pixel(x, y, Color(map[x][y] if map[x][y] > 0 else 0, 0, 0))
			img.put_pixel(x, y, col)
			
	var tex = ImageTexture.new()
	tex.create(width, height, Image.FORMAT_RGB)
	tex.set_data(img)
	tex.set_flags(tex.FLAG_REPEAT)
	get_node("Map").set_texture(tex)
	get_node("Map").set_region_rect(Rect2(0, 0, width*2, height*2))
	print("eroded")

#func _draw():
#	if(map.size() != 0):
#		for x in range(width):
#			for y in range(height):
#				var col
#				if(map[x][y] <= 0.3):
#					col = Color(0.0, 0.0, 0.5)
#				elif(map[x][y] <= 0.55):
#					col = Color(0.2, 0.2, 1.0)
#				elif(map[x][y] <= 0.6):
#					col = Color(0.4, 0.4, 1.0)
#				elif(map[x][y] <= 0.62):
#					col = Color(0.76, 0.70, 0.50)
#				elif(map[x][y] <= 0.68):
#					col = Color(0.49, 0.99, 0)
#				elif(map[x][y] <= 0.75):
#					col = Color(0, 0.50, 0)
#				elif(map[x][y] <= 0.82):
#					col = Color(0.54, 0.27, 0.07)
#				elif(map[x][y] <= 0.95):
#					col = Color(0.66, 0.66, 0.66)
#				else:
#					col = Color(1.0, 1.0, 1.0)
#					
#				draw_rect(Rect2(x * tileSize, y * tileSize, tileSize, tileSize), col)
#				draw_rect(Rect2(x * tileSize + width * tileSize, y * tileSize, tileSize, tileSize), col)
#				draw_rect(Rect2(x * tileSize, y * tileSize + height * tileSize, tileSize, tileSize), col)
#				draw_rect(Rect2(x * tileSize + width * tileSize, y * tileSize + height * tileSize, tileSize, tileSize), col)
				
func _input(ev):
	if(ev.type == InputEvent.MOUSE_BUTTON && !ev.pressed):
		mouseP = ev.pos
		CreateMap()
	elif(ev.type == InputEvent.KEY && !ev.pressed):
		if(ev.scancode == KEY_0):
			Erode()
	
func _ready():
	seed(OS.get_time().second)
	map = ProcUtil.MapOne2D(width, height)
	set_process_input(true)
