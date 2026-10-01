extends Node3D

# Gam Piyasa v0.2.1
# Mobile-friendly procedural Sri Lankan village + walawwa environment.
# The art style is still prototype/stylized, but the layout and visual language
# are designed so we can replace primitives with authored 3D assets later.

var wood_dark := Color("4a2f20")
var wood_mid := Color("6b442c")
var plaster := Color("e4d6b6")
var tile_red := Color("8a3f31")
var stone := Color("8c8375")
var grass := Color("557b3b")
var grass_light := Color("6f9650")
var paddy_green := Color("8fae46")
var water_blue := Color("4d8795")

func _ready() -> void:
	build_environment()

func _mat(c: Color, roughness: float = 0.9, metallic: float = 0.0) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = roughness
	m.metallic = metallic
	return m

func _water_mat() -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = Color(0.23, 0.53, 0.60, 0.78)
	m.roughness = 0.22
	m.metallic = 0.08
	m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _box(parent: Node, p: Vector3, s: Vector3, c: Color, collide: bool = false) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = s
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	if collide:
		var body: StaticBody3D = StaticBody3D.new()
		var shape_node: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = s
		shape_node.shape = shape
		body.add_child(shape_node)
		n.add_child(body)
	return n

func _water_box(parent: Node, p: Vector3, s: Vector3) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = s
	mesh.material = _water_mat()
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func _cylinder(parent: Node, p: Vector3, radius: float, height: float, c: Color, sides: int = 10) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = sides
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func _sphere(parent: Node, p: Vector3, radius: float, c: Color) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 10
	mesh.rings = 5
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func build_environment() -> void:
	name = "Environment_v0_2_1"
	_build_ground_and_road()
	_build_paddy_fields()
	_build_canal()
	_build_village_trees()
	_build_fences_and_poles()
	_build_walawwa()
	_build_garden_and_backyard()

func _build_ground_and_road() -> void:
	_box(self, Vector3(0.0, -0.45, 10.0), Vector3(110.0, 0.8, 135.0), grass, true)
	# Main village road used by the intro car.
	_box(self, Vector3(0.0, -0.01, -9.0), Vector3(6.7, 0.10, 70.0), Color("5a5751"), false)
	_box(self, Vector3(-4.2, -0.02, -9.0), Vector3(1.3, 0.08, 70.0), Color("8a795e"), false)
	_box(self, Vector3(4.2, -0.02, -9.0), Vector3(1.3, 0.08, 70.0), Color("8a795e"), false)
	# Driveway into walawwa.
	_box(self, Vector3(0.0, 0.01, 18.7), Vector3(7.8, 0.12, 19.0), Color("947c5d"), false)
	for i in range(11):
		var stone_x: float = -2.6 + float(i % 3) * 2.5
		var stone_z: float = 11.0 + float(i) * 1.15
		_box(self, Vector3(stone_x, 0.10, stone_z), Vector3(1.3, 0.08, 0.7), Color("a28e70"), false)

func _build_paddy_fields() -> void:
	var plots: Array[Vector4] = [
		Vector4(-25.0, -12.0, 22.0, 36.0),
		Vector4(-25.0, 27.0, 22.0, 26.0),
		Vector4(24.0, -14.0, 24.0, 34.0),
		Vector4(24.0, 26.0, 24.0, 25.0)
	]
	for plot: Vector4 in plots:
		_box(self, Vector3(plot.x, -0.05, plot.y), Vector3(plot.z, 0.08, plot.w), paddy_green, false)
		_build_paddy_rows(Vector3(plot.x, 0.05, plot.y), Vector2(plot.z, plot.w))

func _build_paddy_rows(center: Vector3, size: Vector2) -> void:
	# Thin crop lines: visually dense without using hundreds of individual plants.
	var row_count: int = 8
	for i in range(row_count):
		var t: float = float(i) / float(row_count - 1)
		var x: float = center.x - size.x * 0.42 + size.x * 0.84 * t
		var row: MeshInstance3D = _box(self, Vector3(x, center.y + 0.17, center.z), Vector3(0.22, 0.35, size.y * 0.86), grass_light, false)
		row.rotation_degrees.y = 0.0

func _build_canal() -> void:
	# Irrigation canal on the left side of the road.
	_box(self, Vector3(-10.8, 0.05, -4.0), Vector3(5.8, 0.55, 78.0), Color("6c5b47"), false)
	_water_box(self, Vector3(-10.8, 0.22, -4.0), Vector3(3.6, 0.12, 77.0))
	_box(self, Vector3(-13.1, 0.35, -4.0), Vector3(0.8, 0.65, 78.0), Color("64734d"), false)
	_box(self, Vector3(-8.5, 0.35, -4.0), Vector3(0.8, 0.65, 78.0), Color("64734d"), false)
	# Small wooden footbridge near the house.
	for i in range(7):
		_box(self, Vector3(-10.8 + float(i - 3) * 0.65, 0.65, 15.0), Vector3(0.55, 0.16, 2.3), wood_mid, true)
	_box(self, Vector3(-10.8, 1.15, 13.95), Vector3(4.7, 0.13, 0.12), wood_dark, false)
	_box(self, Vector3(-10.8, 1.15, 16.05), Vector3(4.7, 0.13, 0.12), wood_dark, false)

func _build_village_trees() -> void:
	var tree_positions: Array[Vector3] = [
		Vector3(-17,0,-27), Vector3(15,0,-31), Vector3(-20,0,-15), Vector3(20,0,-10),
		Vector3(-18,0,4), Vector3(18,0,3), Vector3(-20,0,18), Vector3(20,0,17),
		Vector3(-26,0,40), Vector3(26,0,40), Vector3(-13,0,48), Vector3(13,0,48),
		Vector3(-31,0,5), Vector3(31,0,5), Vector3(-34,0,-22), Vector3(34,0,-18)
	]
	for p: Vector3 in tree_positions:
		_make_mango_tree(p)
	# Coconut silhouettes along field edges.
	for p: Vector3 in [Vector3(-34,0,-4), Vector3(33,0,16), Vector3(-32,0,28), Vector3(31,0,-30)]:
		_make_coconut_tree(p)
	# Banana groups around the walawwa backyard.
	for p: Vector3 in [Vector3(-9,0,39), Vector3(-6,0,42), Vector3(9,0,41), Vector3(12,0,38)]:
		_make_banana(p)

func _make_mango_tree(p: Vector3) -> void:
	var n: Node3D = Node3D.new()
	n.position = p
	self.add_child(n)
	_cylinder(n, Vector3(0, 2.0, 0), 0.42, 4.0, Color("6c4730"), 9)
	_sphere(n, Vector3(0, 5.0, 0), 2.35, Color("32663d"))
	_sphere(n, Vector3(-1.5, 4.65, 0.25), 1.55, Color("3d7543"))
	_sphere(n, Vector3(1.45, 4.75, -0.25), 1.55, Color("356d3d"))
	_sphere(n, Vector3(0.2, 5.6, 1.0), 1.4, Color("477f49"))

func _make_coconut_tree(p: Vector3) -> void:
	var n: Node3D = Node3D.new()
	n.position = p
	self.add_child(n)
	var trunk: MeshInstance3D = _cylinder(n, Vector3(0, 4.0, 0), 0.32, 8.0, Color("73533a"), 9)
	trunk.rotation_degrees.z = 4.0
	for i in range(7):
		var angle: float = float(i) * 360.0 / 7.0
		var leaf: MeshInstance3D = _box(n, Vector3(0, 8.0, 0), Vector3(0.34, 0.08, 4.0), Color("2c703c"), false)
		leaf.rotation_degrees = Vector3(-16.0, angle, 0.0)
		leaf.position += Vector3(sin(deg_to_rad(angle)) * 1.6, 0.0, cos(deg_to_rad(angle)) * 1.6)

func _make_banana(p: Vector3) -> void:
	var n: Node3D = Node3D.new()
	n.position = p
	self.add_child(n)
	_cylinder(n, Vector3(0, 1.7, 0), 0.20, 3.4, Color("7e914f"), 8)
	for i in range(6):
		var angle: float = float(i) * 60.0
		var leaf: MeshInstance3D = _box(n, Vector3.ZERO, Vector3(0.28, 0.06, 3.1), Color("4b8d46"), false)
		leaf.position = Vector3(sin(deg_to_rad(angle))*1.15, 3.45, cos(deg_to_rad(angle))*1.15)
		leaf.rotation_degrees = Vector3(-18.0, angle, 0.0)

func _build_fences_and_poles() -> void:
	# Timber fence separating road from fields.
	for side in [-1.0, 1.0]:
		var x: float = 6.5 * side
		for i in range(14):
			var z: float = -34.0 + float(i) * 4.2
			_cylinder(self, Vector3(x, 0.7, z), 0.09, 1.4, wood_mid, 7)
			_box(self, Vector3(x, 0.85, z + 2.0), Vector3(0.12, 0.10, 4.0), wood_mid, false)
	# Power poles and crossbars.
	for i in range(6):
		var z: float = -31.0 + float(i) * 11.0
		_cylinder(self, Vector3(7.9, 3.0, z), 0.16, 6.0, Color("6b6256"), 8)
		_box(self, Vector3(7.9, 5.7, z), Vector3(2.5, 0.15, 0.15), Color("5f574e"), false)

func _build_walawwa() -> void:
	var h: Node3D = Node3D.new()
	h.name = "Walawwa_v0_2_3"
	self.add_child(h)
	# Foundation and timber floor.
	_box(h, Vector3(0, 0.18, 30.0), Vector3(19.0, 0.36, 16.0), stone, true)
	_box(h, Vector3(0, 0.43, 30.0), Vector3(17.7, 0.18, 14.6), Color("775137"), true)
	# Exterior walls with wide central entrance.
	_box(h, Vector3(-7.6, 2.6, 37.2), Vector3(2.3, 4.7, 0.45), plaster, true)
	_box(h, Vector3(7.6, 2.6, 37.2), Vector3(2.3, 4.7, 0.45), plaster, true)
	_box(h, Vector3(0, 4.35, 37.2), Vector3(13.0, 1.2, 0.45), plaster, true)
	_box(h, Vector3(-8.8, 2.6, 30.0), Vector3(0.45, 4.7, 14.5), plaster, true)
	_box(h, Vector3(8.8, 2.6, 30.0), Vector3(0.45, 4.7, 14.5), plaster, true)
	# Front facade leaves a real walk-through doorway instead of a solid collider wall.
	_box(h, Vector3(-5.75, 2.6, 22.8), Vector3(6.3, 4.7, 0.45), plaster, true)
	_box(h, Vector3(5.75, 2.6, 22.8), Vector3(6.3, 4.7, 0.45), plaster, true)
	_box(h, Vector3(0, 4.45, 22.8), Vector3(5.2, 1.0, 0.45), plaster, true)
	# Deep front veranda, columns, and timber railing.
	_box(h, Vector3(0, 0.40, 20.8), Vector3(20.5, 0.32, 4.2), stone, true)
	for x in [-8.2, -5.4, -2.7, 2.7, 5.4, 8.2]:
		_cylinder(h, Vector3(x, 2.65, 20.2), 0.20, 4.5, wood_dark, 8)
		_box(h, Vector3(x, 4.75, 20.2), Vector3(0.35, 0.28, 0.35), Color("c9b08a"), false)
	_box(h, Vector3(0, 4.7, 20.2), Vector3(18.4, 0.30, 0.35), wood_dark, false)
	# v0.2.3 corrected gable roof: both halves rise toward the central ridge.
	var left_roof: MeshInstance3D = _box(h, Vector3(-4.65, 5.82, 29.7), Vector3(10.3, 0.34, 19.2), tile_red, false)
	left_roof.rotation_degrees.z = 12.0
	var right_roof: MeshInstance3D = _box(h, Vector3(4.65, 5.82, 29.7), Vector3(10.3, 0.34, 19.2), Color("994737"), false)
	right_roof.rotation_degrees.z = -12.0
	# Dark ridge cap and fascia give the roof a finished old-walawwa silhouette.
	_box(h, Vector3(0.0, 6.83, 29.7), Vector3(0.42, 0.38, 19.6), wood_dark, false)
	_box(h, Vector3(-9.55, 4.78, 29.7), Vector3(0.28, 0.28, 19.5), wood_dark, false)
	_box(h, Vector3(9.55, 4.78, 29.7), Vector3(0.28, 0.28, 19.5), wood_dark, false)
	# Tile rhythm strips make the roof read less like a single flat slab.
	for z in [21.6, 24.8, 28.0, 31.2, 34.4, 37.6]:
		var tile_l: MeshInstance3D = _box(h, Vector3(-4.65, 5.85, z), Vector3(10.15, 0.06, 0.12), Color("7f392e"), false)
		tile_l.rotation_degrees.z = 12.0
		var tile_r: MeshInstance3D = _box(h, Vector3(4.65, 5.85, z), Vector3(10.15, 0.06, 0.12), Color("843a2f"), false)
		tile_r.rotation_degrees.z = -12.0
	# Timber beams under roof.
	for z in [24.0, 28.0, 32.0, 36.0]:
		_box(h, Vector3(0, 4.55, z), Vector3(17.2, 0.22, 0.22), wood_dark, false)
	# Front entrance frame and carved-looking double timber doors.
	_box(h, Vector3(-2.35, 2.5, 22.52), Vector3(0.34, 4.15, 0.34), wood_dark, false)
	_box(h, Vector3(2.35, 2.5, 22.52), Vector3(0.34, 4.15, 0.34), wood_dark, false)
	_box(h, Vector3(0, 4.48, 22.52), Vector3(5.05, 0.34, 0.34), wood_dark, false)
	var door_l: MeshInstance3D = _box(h, Vector3(-2.72, 2.32, 23.05), Vector3(2.08, 3.72, 0.22), wood_mid, false)
	door_l.rotation_degrees.y = -38.0
	var door_r: MeshInstance3D = _box(h, Vector3(2.72, 2.32, 23.05), Vector3(2.08, 3.72, 0.22), wood_mid, false)
	door_r.rotation_degrees.y = 38.0
	for y in [1.25, 2.25, 3.25]:
		_box(door_l, Vector3(0, y-2.32, -0.13), Vector3(1.45, 0.10, 0.05), Color("4c2d1f"), false)
		_box(door_r, Vector3(0, y-2.32, -0.13), Vector3(1.45, 0.10, 0.05), Color("4c2d1f"), false)
	_sphere(h, Vector3(-1.95, 2.28, 21.92), 0.08, Color("c8a85d"))
	_sphere(h, Vector3(1.95, 2.28, 21.92), 0.08, Color("c8a85d"))
	# Framed front windows with crossbars and timber shutters.
	for x in [-6.25, 6.25]:
		_box(h, Vector3(x, 2.72, 22.48), Vector3(2.75, 2.15, 0.16), Color("496a71"), false)
		_box(h, Vector3(x, 2.72, 22.34), Vector3(3.10, 0.18, 0.20), wood_dark, false)
		_box(h, Vector3(x, 2.72, 22.34), Vector3(0.18, 2.48, 0.20), wood_dark, false)
		_box(h, Vector3(x, 1.55, 22.34), Vector3(3.10, 0.18, 0.20), wood_dark, false)
		_box(h, Vector3(x, 3.89, 22.34), Vector3(3.10, 0.18, 0.20), wood_dark, false)
		_box(h, Vector3(x-1.72, 2.72, 22.28), Vector3(0.78, 2.35, 0.16), wood_mid, false)
		_box(h, Vector3(x+1.72, 2.72, 22.28), Vector3(0.78, 2.35, 0.16), wood_mid, false)
	# Main hall furniture.
	_box(h, Vector3(-4.8, 1.0, 30.0), Vector3(4.2, 0.55, 1.5), wood_mid, true)
	_box(h, Vector3(-4.8, 1.9, 30.7), Vector3(4.2, 1.5, 0.35), wood_dark, false)
	_box(h, Vector3(4.5, 1.05, 31.5), Vector3(4.8, 0.25, 2.3), wood_mid, true)
	for sx in [-1.9, 1.9]:
		for sz in [-0.7, 0.7]:
			_cylinder(h, Vector3(4.5 + sx, 0.68, 31.5 + sz), 0.12, 1.2, wood_dark, 7)
	# Old central clock cabinet.
	_box(h, Vector3(7.2, 1.75, 34.7), Vector3(1.15, 2.9, 0.65), wood_dark, true)
	_sphere(h, Vector3(7.2, 2.35, 34.34), 0.38, Color("d5c79f"))
	# Family photo panels on back wall.
	for x in [-4.0, 0.0, 4.0]:
		_box(h, Vector3(x, 3.05, 36.93), Vector3(2.1, 1.7, 0.10), wood_dark, false)
		_box(h, Vector3(x, 3.05, 36.85), Vector3(1.7, 1.3, 0.08), Color("a78f72"), false)
	# Warm indoor lanterns.
	for x in [-4.5, 4.5]:
		var light: OmniLight3D = OmniLight3D.new()
		light.position = Vector3(x, 4.0, 30.0)
		light.light_color = Color("ffd3a0")
		light.light_energy = 2.4
		light.omni_range = 8.0
		h.add_child(light)

func _build_garden_and_backyard() -> void:
	# Flower beds at the veranda.
	for x in [-7.4, -5.7, 5.7, 7.4]:
		_box(self, Vector3(x, 0.18, 18.0), Vector3(1.25, 0.30, 1.25), Color("4c6a39"), false)
		_sphere(self, Vector3(x, 0.78, 18.0), 0.55, Color("6f9a52"))
	# Side paths around the house for exploration.
	_box(self, Vector3(-10.0, 0.03, 31.0), Vector3(2.0, 0.10, 19.0), Color("8f7658"), false)
	_box(self, Vector3(10.0, 0.03, 31.0), Vector3(2.0, 0.10, 19.0), Color("8f7658"), false)
	# Backyard open space for later hand-washing mission.
	_box(self, Vector3(0.0, 0.00, 43.0), Vector3(18.0, 0.08, 9.0), Color("69824b"), false)
	# Prototype wash platform.
	_box(self, Vector3(-5.4, 0.38, 43.0), Vector3(3.0, 0.55, 2.5), stone, true)
	_cylinder(self, Vector3(-5.4, 1.35, 43.0), 0.12, 1.5, Color("6e6e68"), 8)
	var tap: MeshInstance3D = _box(self, Vector3(-4.9, 1.8, 43.0), Vector3(0.9, 0.12, 0.12), Color("777a78"), false)
	tap.rotation_degrees.y = 0.0
	_water_box(self, Vector3(-4.45, 1.45, 43.0), Vector3(0.08, 0.75, 0.08))
