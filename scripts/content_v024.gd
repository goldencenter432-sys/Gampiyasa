extends Node3D

# Gam Piyasa v0.2.4 content expansion.
# Adds a larger explorable village footprint and detailed walawwa rooms.

var grass_outer := Color("5f8247")
var paddy_a := Color("86a846")
var paddy_b := Color("779b3f")
var soil := Color("79654c")
var wood_dark := Color("4b3022")
var wood_mid := Color("765039")
var wall := Color("ded1b7")
var stone := Color("8b8172")

func _ready() -> void:
	name = "Content_v0_2_4"
	_build_map_extension()
	_build_extended_road_and_canal()
	_build_outer_vegetation()
	_build_walawwa_rooms()
	_build_kitchen()
	_build_photo_gallery()
	_build_bedroom_and_store()
	_build_room_lighting()

func _mat(c: Color, roughness: float = 0.9) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = roughness
	if c.a < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _box(parent: Node, p: Vector3, s: Vector3, c: Color, collide: bool = false) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = s
	mesh.material = _mat(c)
	node.mesh = mesh
	node.position = p
	parent.add_child(node)
	if collide:
		var body: StaticBody3D = StaticBody3D.new()
		var shape_node: CollisionShape3D = CollisionShape3D.new()
		var shape: BoxShape3D = BoxShape3D.new()
		shape.size = s
		shape_node.shape = shape
		body.add_child(shape_node)
		node.add_child(body)
	return node

func _sphere(parent: Node, p: Vector3, radius: float, c: Color) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = radius
	mesh.height = radius * 2.0
	mesh.radial_segments = 9
	mesh.rings = 5
	mesh.material = _mat(c)
	node.mesh = mesh
	node.position = p
	parent.add_child(node)
	return node

func _cylinder(parent: Node, p: Vector3, radius: float, height: float, c: Color) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = radius
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = 8
	mesh.material = _mat(c)
	node.mesh = mesh
	node.position = p
	parent.add_child(node)
	return node

func _build_map_extension() -> void:
	# The old playable footprint ended quickly behind the house/road.
	# This lower slab extends the same floor level to create a larger map.
	_box(self, Vector3(0.0,-0.55,7.0), Vector3(180.0,1.0,220.0), grass_outer, true)

	# Additional paddy zones farther from the original village core.
	var plots: Array[Vector4] = [
		Vector4(-33.0,-66.0,42.0,40.0),
		Vector4(31.0,-67.0,40.0,39.0),
		Vector4(-48.0,78.0,36.0,42.0),
		Vector4(47.0,76.0,35.0,40.0)
	]
	for p: Vector4 in plots:
		_box(self, Vector3(p.x,-0.02,p.y), Vector3(p.z,0.08,p.w), paddy_a if int(abs(p.x)) % 2 == 0 else paddy_b, false)
		# Low mud bunds frame each field.
		_box(self, Vector3(p.x,0.08,p.y-p.w*0.5), Vector3(p.z,0.18,0.45), soil, false)
		_box(self, Vector3(p.x,0.08,p.y+p.w*0.5), Vector3(p.z,0.18,0.45), soil, false)

func _build_extended_road_and_canal() -> void:
	# Continue the same village road well beyond the v0.2.3 starting point.
	_box(self, Vector3(0.0,0.00,-66.0), Vector3(6.7,0.11,46.0), Color("575754"), false)
	_box(self, Vector3(-4.2,-0.01,-66.0), Vector3(1.3,0.08,46.0), Color("8c795d"), false)
	_box(self, Vector3(4.2,-0.01,-66.0), Vector3(1.3,0.08,46.0), Color("8c795d"), false)

	# Extend the irrigation canal beside the road.
	_box(self, Vector3(-10.8,0.04,-65.0), Vector3(5.8,0.55,44.0), Color("675846"), false)
	var water: MeshInstance3D = _box(self, Vector3(-10.8,0.22,-65.0), Vector3(3.6,0.12,43.0), Color(0.28,0.55,0.61,0.82), false)
	var wm: StandardMaterial3D = water.mesh.material
	wm.roughness = 0.2

	# A second little footbridge gives the larger map another landmark.
	for i: int in range(7):
		_box(self, Vector3(-10.8+float(i-3)*0.65,0.65,-53.0), Vector3(0.55,0.16,2.2), wood_mid, true)

func _make_tree(p: Vector3, scale_v: float = 1.0) -> void:
	var root: Node3D = Node3D.new()
	root.position = p
	root.scale = Vector3.ONE * scale_v
	add_child(root)
	_cylinder(root,Vector3(0,2.0,0),0.38,4.0,Color("6a4932"))
	_sphere(root,Vector3(0,5.0,0),2.2,Color("32683c"))
	_sphere(root,Vector3(-1.3,4.7,0.4),1.45,Color("3e7844"))
	_sphere(root,Vector3(1.2,4.8,-0.3),1.35,Color("467f49"))

func _build_outer_vegetation() -> void:
	var trees: Array[Vector3] = [
		Vector3(-18,0,-82),Vector3(18,0,-80),Vector3(-28,0,-72),Vector3(30,0,-71),
		Vector3(-43,0,-49),Vector3(42,0,-50),Vector3(-58,0,48),Vector3(58,0,50),
		Vector3(-65,0,84),Vector3(64,0,82),Vector3(-25,0,98),Vector3(27,0,101),
		Vector3(-70,0,8),Vector3(70,0,12),Vector3(-76,0,-25),Vector3(77,0,-18)
	]
	for i: int in range(trees.size()):
		_make_tree(trees[i],0.85+float(i%4)*0.10)

	# Distant low hills hide the edge of the expanded playable map.
	for i: int in range(10):
		var x: float = -72.0 + float(i)*16.0
		var hill: MeshInstance3D = _sphere(self,Vector3(x,3.0,111.0+float(i%2)*5.0),9.5,Color("55744c"))
		hill.scale = Vector3(1.8,0.55,1.0)

func _build_walawwa_rooms() -> void:
	var rooms: Node3D = Node3D.new()
	rooms.name = "WalawwaRooms_v0_2_4"
	add_child(rooms)

	# Back half of the walawwa is now divided into separate rooms.
	# Horizontal partition leaves a central doorway from the main hall.
	_box(rooms,Vector3(-5.2,2.25,30.55),Vector3(7.0,3.7,0.28),wall,true)
	_box(rooms,Vector3(5.2,2.25,30.55),Vector3(7.0,3.7,0.28),wall,true)

	# Vertical divider creates a left kitchen and right bedroom/store area.
	_box(rooms,Vector3(0.0,2.25,32.0),Vector3(0.28,3.7,2.4),wall,true)
	_box(rooms,Vector3(0.0,2.25,36.0),Vector3(0.28,3.7,2.2),wall,true)

	# Timber trims around the central hall doorway.
	_box(rooms,Vector3(-1.65,2.3,30.35),Vector3(0.22,3.8,0.22),wood_dark,false)
	_box(rooms,Vector3(1.65,2.3,30.35),Vector3(0.22,3.8,0.22),wood_dark,false)
	_box(rooms,Vector3(0.0,4.1,30.35),Vector3(3.5,0.22,0.22),wood_dark,false)

	# Side room door trims at the inner divider.
	for z: float in [33.2,34.8]:
		_box(rooms,Vector3(0.0,2.15,z),Vector3(0.18,3.5,0.75),wood_mid,false)

func _build_kitchen() -> void:
	var k: Node3D = Node3D.new()
	k.name = "Kitchen_v0_2_4"
	add_child(k)

	# Left-back kitchen counters.
	_box(k,Vector3(-5.8,0.95,35.9),Vector3(5.0,1.15,0.9),wood_mid,true)
	_box(k,Vector3(-7.6,0.95,33.7),Vector3(0.9,1.15,3.6),wood_mid,true)
	_box(k,Vector3(-5.8,1.58,35.9),Vector3(5.1,0.12,1.0),Color("776c5e"),false)

	# Stove/hearth.
	_box(k,Vector3(-3.8,0.82,35.6),Vector3(1.35,0.75,1.1),Color("55514a"),true)
	for x: float in [-4.15,-3.45]:
		_cylinder(k,Vector3(x,1.28,35.6),0.22,0.12,Color("222222"))

	# Sink and tap.
	_box(k,Vector3(-6.3,1.66,35.75),Vector3(1.4,0.12,0.75),Color("777b79"),false)
	_cylinder(k,Vector3(-6.3,1.95,35.75),0.07,0.55,Color("8b8d88"))

	# Shelves and pots.
	_box(k,Vector3(-7.95,2.75,35.6),Vector3(0.18,0.18,3.0),wood_dark,false)
	for z: float in [34.7,35.6,36.5]:
		_box(k,Vector3(-7.75,2.55,z),Vector3(0.65,0.12,0.55),wood_mid,false)
		_cylinder(k,Vector3(-7.55,2.78,z),0.18,0.30,Color("4f4e4a"))

	# Small kitchen table.
	_box(k,Vector3(-4.5,1.05,32.9),Vector3(2.4,0.18,1.6),wood_mid,true)
	for x: float in [-1.0,1.0]:
		for z: float in [-0.6,0.6]:
			_cylinder(k,Vector3(-4.5+x,0.55,32.9+z),0.09,1.0,wood_dark)

func _build_photo_gallery() -> void:
	var gallery: Node3D = Node3D.new()
	gallery.name = "FamilyPhotos_v0_2_4"
	add_child(gallery)

	# Photo gallery on the new partition facing the main hall.
	var xs: Array[float] = [-6.4,-4.6,-2.8,2.8,4.6,6.4]
	for i: int in range(xs.size()):
		var x: float = xs[i]
		var frame_color: Color = Color("4d3226")
		var photo_color: Color = Color("aa947b") if i%2==0 else Color("8d9a83")
		_box(gallery,Vector3(x,2.75,30.36),Vector3(1.35,1.55,0.10),frame_color,false)
		_box(gallery,Vector3(x,2.75,30.29),Vector3(1.05,1.25,0.08),photo_color,false)

	# One larger ancestral portrait in the center rear corridor.
	_box(gallery,Vector3(-0.20,2.85,36.90),Vector3(1.8,2.0,0.10),frame_color,false)
	_box(gallery,Vector3(-0.20,2.85,36.82),Vector3(1.45,1.65,0.08),Color("9f8770"),false)

func _build_bedroom_and_store() -> void:
	var b: Node3D = Node3D.new()
	b.name = "BedroomAndStore_v0_2_4"
	add_child(b)

	# Right-back bedroom.
	_box(b,Vector3(5.5,0.75,35.3),Vector3(4.2,0.55,2.2),Color("704d36"),true)
	_box(b,Vector3(5.5,1.05,35.3),Vector3(3.8,0.20,1.9),Color("c7b08f"),false)
	_box(b,Vector3(5.5,1.28,36.0),Vector3(1.7,0.22,0.70),Color("e0d3bb"),false)

	# Tall old cupboard.
	_box(b,Vector3(7.55,1.75,32.3),Vector3(1.20,2.9,0.85),wood_dark,true)
	_box(b,Vector3(7.25,1.75,31.82),Vector3(0.08,2.4,0.08),Color("c29c59"),false)

	# Small side table and storage chest.
	_box(b,Vector3(3.4,0.78,32.5),Vector3(1.2,0.18,1.0),wood_mid,true)
	_box(b,Vector3(5.8,0.62,32.4),Vector3(1.8,0.75,1.1),Color("5d3c2b"),true)

func _build_room_lighting() -> void:
	var kitchen_light: OmniLight3D = OmniLight3D.new()
	kitchen_light.position = Vector3(-5.0,3.5,34.2)
	kitchen_light.light_color = Color("ffd4a3")
	kitchen_light.light_energy = 1.8
	kitchen_light.omni_range = 6.0
	add_child(kitchen_light)

	var room_light: OmniLight3D = OmniLight3D.new()
	room_light.position = Vector3(5.2,3.5,34.2)
	room_light.light_color = Color("f4d4ad")
	room_light.light_energy = 1.6
	room_light.omni_range = 5.5
	add_child(room_light)
