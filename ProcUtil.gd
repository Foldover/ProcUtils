extends Node

var p = [151,160,137,91,90,15,
			131,13,201,95,96,53,194,233,7,225,140,36,103,30,69,142,8,99,37,240,21,10,23,
			190, 6,148,247,120,234,75,0,26,197,62,94,252,219,203,117,35,11,32,57,177,33,
			88,237,149,56,87,174,20,125,136,171,168, 68,175,74,165,71,134,139,48,27,166,
			77,146,158,231,83,111,229,122,60,211,133,230,220,105,92,41,55,46,245,40,244,
			102,143,54, 65,25,63,161, 1,216,80,73,209,76,132,187,208, 89,18,169,200,196,
			135,130,116,188,159,86,164,100,109,198,173,186, 3,64,52,217,226,250,124,123,
			5,202,38,147,118,126,255,82,85,212,207,206,59,227,47,16,58,17,182,189,28,42,
			223,183,170,213,119,248,152, 2,44,154,163, 70,221,153,101,155,167, 43,172,9,
			129,22,39,253, 19,98,108,110,79,113,224,232,178,185, 112,104,218,246,97,228,
			251,34,242,193,238,210,144,12,191,179,162,241, 81,51,145,235,249,14,239,107,
			49,192,214, 31,181,199,106,157,184, 84,204,176,115,121,50,45,127, 4,150,254,
			138,236,205,93,222,114,67,29,24,72,243,141,128,195,78,66,215,61,156,180]
var permutation = p

static func _fade(t):
	return t * t * t * (t * (t * 6 - 15) + 10)

static func _lerp(t, a, b):
	return a + t * (b - a)
	
static func _grad(h, x, y, z):
	var hh = h & 15
	var u = x if hh < 8 else y
	var v = y if hh < 4 else x if hh == 12 or hh == 14 else z
	
	return ((u if hh & 1 == 0 else -u) + (v if hh & 2 == 0 else -v))

func PerlinNoise(x, y, z):
	var X = int(floor(x)) & 255
	var Y = int(floor(y)) & 255
	var Z = int(floor(z)) & 255
	
	x -= floor(x)
	y -= floor(y)
	z -= floor(z)
	
	var u = _fade(x)
	var v = _fade(y)
	var w = _fade(z)
	
	var A = p[X] + Y
	var AA = p[A] + Z
	var AB = p[A + 1] + Z
	var B = p[X + 1] + Y
	var BA = p[B] + Z
	var BB = p[B + 1] + Z

	return _lerp(w, _lerp(v, _lerp(u, _grad(p[AA], x, y, z),
									  _grad(p[BA], x-1, y, z)),
							 _lerp(u, _grad(p[AB], x, y-1, z),
									  _grad(p[BB], x-1, y-1, z))),
					_lerp(v, _lerp(u, _grad(p[AA+1], x, y, z-1),
									  _grad(p[BA+1], x-1, y, z-1)),
							 _lerp(u, _grad(p[AB+1], x, y-1, z-1),
									  _grad(p[BB+1], x-1, y-1, z-1))))

func PerlinMap(map, width, height, xoff, yoff, octaves, persistence, lacunarity, zoom):
	for x in range(width):
		for y in range(height):
			var total = 0.0
			var frequency = 1.0
			var amplitude = 1.0
			for i in range(octaves):
				var sx = x / zoom * frequency + xoff
				var sy = y / zoom * frequency + yoff
				total += (PerlinNoise(sx, sy, 0.5) + 1.0) * 0.5 * amplitude
				amplitude *= persistence
				frequency *= lacunarity
			map[x][y] = total

func AsteroidalBombardment(map, width, height, n_ast, min_size, max_size, min_force, max_force, evap, pos = null):
	for n in range(n_ast):
		var size = int(rand_range(min_size, max_size))
		var R = size * 0.5
		var force = rand_range(min_force, max_force)
		var impactPos
		if pos == null:
			impactPos = [int(rand_range(0, width)), int(rand_range(0, height))]
		else:
			impactPos = [int(pos.x), int(pos.y)]
		var y = int(impactPos[1] - R)
		while y < int(impactPos[1] + R):
			var r = sqrt(R*R-(y-impactPos[1])*(y-impactPos[1]))
			var x = int(impactPos[0] - r)
			while x < int(impactPos[0] + r):
				var rx
				var ry
				if(y >= height):
					ry = y - height
				elif(y < 0):
					ry = height + y
				else:
					ry = y
					
				if(x >= width):
					rx = x - width
				elif(x < 0):
					rx = width + x
				else:
					rx = x
					
				var forceMod = sqrt((x - impactPos[0])*(x - impactPos[0]) + (y - impactPos[1])*(y - impactPos[1])) / R
				if(forceMod > 1.0):
					forceMod = 1.0
				elif(forceMod < 0.0):
					forceMod = 0.0
				forceMod = abs(forceMod-1)
				map[rx][ry] -= force * forceMod
				x += 1
			y += 1

func HydraulicErosion(map, width, height, millenias, water, solubility, evap, capacity):
	var waterMap = MapZero2D(width, height)
	var sedimentMap = MapZero2D(width, height)
	
	for p in range(millenias):
		for x in range(width):
			for y in range(height):
				waterMap[x][y] += water
				var dissSed = solubility * waterMap[x][y]
				sedimentMap[x][y] += dissSed
				map[x][y] -= dissSed
				
		for x in range(width):
			for y in range(height):
				var alt = map[x][y] + waterMap[x][y]
				var da = alt - (((map[x-1 if x-1 >= 0 else width-1][y] + waterMap[x-1 if x-1 >= 0 else width-1][y]) + 
								(map[x+1 if x+1 < width else 0][y] + waterMap[x+1 if x+1 < width else 0][y]) +
								(map[x][y-1 if y-1 >= 0 else height-1] + waterMap[x][y-1 if y-1 >= 0 else height-1]) +
								(map[x][y+1 if y+1 < height else 0] + waterMap[x][y+1 if y+1 < height else 0]))
								/ 4.0)
				
				var d1 = alt - (map[x-1 if x-1 >= 0 else width-1][y] + waterMap[x-1 if x-1 >= 0 else width-1][y])
				var d2 = alt - (map[x+1 if x+1 < width else 0][y] + waterMap[x+1 if x+1 < width else 0][y])
				var d3 = alt - (map[x][y-1 if y-1 >= 0 else height-1] + waterMap[x][y-1 if y-1 >= 0 else height-1])
				var d4 = alt - (map[x][y+1 if y+1 < height else 0] + waterMap[x][y+1 if y+1 < height else 0])
				var dtot = (d1 if d1 > 0 else 0) + (d2 if d2 > 0 else 0) + (d3 if d3 > 0 else 0) + (d4 if d4 > 0 else 0)
				
				var movWater
				var movSed
				
				if d1 > 0:
					movWater = min(waterMap[x][y], da) * (d1/dtot)
					movSed = sedimentMap[x][y] * (movWater/waterMap[x][y])
					waterMap[x-1 if x-1 >= 0 else width-1][y] += movWater
					sedimentMap[x-1 if x-1 >= 0 else width-1][y] += movSed
					sedimentMap[x][y] -= movSed
				
				if d2 > 0:
					movWater = min(waterMap[x][y], da) * (d2/dtot)
					movSed = sedimentMap[x][y] * (movWater/waterMap[x][y])
					waterMap[x+1 if x+1 < width else 0][y] += movWater
					sedimentMap[x+1 if x+1 < width else 0][y] += movSed
					sedimentMap[x][y] -= movSed
				
				if d3 > 0:
					movWater = min(waterMap[x][y], da) * (d3/dtot)
					movSed = sedimentMap[x][y] * (movWater/waterMap[x][y])
					waterMap[x][y-1 if y-1 >= 0 else height-1] += movWater
					sedimentMap[x][y-1 if y-1 >= 0 else height-1] += movSed
					sedimentMap[x][y] -= movSed
				
				if d4 > 0:
					movWater = min(waterMap[x][y], da) * (d4/dtot)
					movSed = sedimentMap[x][y] * (movWater/waterMap[x][y])
					waterMap[x][y+1 if y+1 < height else 0] += movWater
					sedimentMap[x][y+1 if y+1 < height else 0] += movSed
					sedimentMap[x][y] -= movSed
				
				waterMap[x][y] = waterMap[x][y] * (1.0 - evap)
				var maxSedMov = capacity * waterMap[x][y]
				var dsed = max(0, sedimentMap[x][y] - maxSedMov)
				sedimentMap[x][y] -= dsed
				map[x][y] += dsed
				
		for x in range(width):
			for y in range(height):
				map[x][y] += sedimentMap[x][y]

func MapZero2D(X, Y):
	var map = []
	for x in range(X):
		map.push_back([])
		for y in range(Y):
			map[x].push_back(0.0)
	return map

func MapOne2D(X, Y):
	var map = []
	for x in range(X):
		map.push_back([])
		for y in range(Y):
			map[x].push_back(1.0)
	return map
	
func ScaleMap(map, width, height, coeff):
	for x in range(width):
		for y in range(height):
			map[x][y] *= coeff
	
func NormalizeMap(map, width, height):
	var maxValue = -2147483647.0
	var neg = 0
	for x in range(width):
		for y in range(height):
			if map[x][y] > maxValue:
				maxValue = map[x][y]
			if map[x][y] < neg:
				neg = map[x][y]
				
	for x in range(width):
		for y in range(height):
			map[x][y] = (map[x][y] + neg) / (maxValue + neg)
			
func _ready():
	for i in range(256):
		p[i] = permutation[i]
		p.push_back(p[i])