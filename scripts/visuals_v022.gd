extends Node3D

# Gam Piyasa v0.2.2 visual polish layer.
# Keeps the build lightweight for Android while adding atmosphere and detail.

var cloud_groups: Array[Node3D] = []
var water_glints: Array[MeshInstance3D] = []
var wind_nodes: Array[Node3D] = []
var elapsed: float = 0.0

func _ready() -> void:
	name = "VisualPolish_v0_2_2"
	_build_clouds()
	_build_road_details()
	_build_paddy_details()
	_build_water_details()
	_build_walawwa_details()
	_build_extra_vegetation()

func _process(delta: float) -> void:
	elapsed += delta
	for i: int in range(cloud_groups.size()):
		var cloud: Node3D = cloud_groups[i]
		cloud.position.x += delta * (0.20 + float(i % 3) * 0.05)
		if cloud.position.x > 44.0:
			cloud.position.x = -44.0
	for i: int in range(water_glints.size()):
		var glint: MeshInstance3D = water_glints[i]
		glint.position.y = 0.305 + sin(elapsed * 1.5 + float(i)) * 0.025
	for i: int in range(wind_nodes.size()):
		var node: Node3D = wind_nodes[i]
		node.rotation_degrees.z = sin(elapsed * 1.2 + float(i) * 0.45) * 1.8

func _material(c: Color, roughness: float = 0.88, unshaded: bool = false) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = roughness
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if c.a < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _box(parent: Node, p: Vector3, s: Vector3, c: Color, roughness: float = 0.88) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = s
	mesh.material = _material(c, roughness)
	node.mesh = mesh
	node.position = p
	parent.add_child(node)
	return node

func _sphere(parent: Node, p: Vector3, r: float, c: Color, unshaded: bool = false) -> MeshInstance3D:
	var node: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mesh.radial_segments = 10
	mesh.rings = 5
	mesh.material = _material(c, 0.95, unshaded)
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
	mesh.material = _material(c)
	node.mesh = mesh
	node.position = p
	parent.add_child(node)
	return node

func _build_clouds() -> void:
	var cloud_specs: Array[Vector3] = [
		Vector3(-26.0, 21.0, -15.0),
		Vector3(18.0, 24.0, -2.0),
		Vector3(-12.0, 20.5, 25.0),
		Vector3(29.0, 23.0, 35.0),
		Vector3(-35.0, 25.0, 48.0)
	]
	for i: int in range(cloud_specs.size()):
		var root: Node3D = Node3D.new()
		root.position = cloud_specs[i]
		add_child(root)
		cloud_groups.append(root)
		var base_color: Color = Color(1.0, 1.0, 1.0, 0.88)
		var a: MeshInstance3D = _sphere(root, Vector3(-2.0, 0.0, 0.0), 2.5, base_color, true)
		var b: MeshInstance3D = _sphere(root, Vector3(0.3, 0.45, 0.0), 3.2, base_color, true)
		var c: MeshInstance3D = _sphere(root, Vector3(2.8, 0.05, 0.2), 2.2, base_color, true)
		var d: MeshInstance3D = _sphere(root, Vector3(0.2, -0.45, 0.0), 3.5, Color(0.92,0.96,1.0,0.82), true)
		a.scale = Vector3(1.4, 0.55, 0.85)
		b.scale = Vector3(1.5, 0.60, 0.90)
		c.scale = Vector3(1.5, 0.52, 0.85)
		d.scale = Vector3(1.8, 0.35, 0.75)

func _build_road_details() -> void:
	# Gravel shoulders and subtle worn patches make the road read less like a flat strip.
	for i: int in range(15):
		var z: float = -34.0 + float(i) * 4.5
		var side: float = -1.0 if i % 2 == 0 else 1.0
		_box(self, Vector3(side * 3.15, 0.06, z), Vector3(0.35, 0.05, 1.8), Color("766b5c"))
	for i: int in range(12):
		var z: float = -30.0 + float(i) * 5.2
		var x: float = -0.8 + float(i % 3) * 0.8
		_box(self, Vector3(x, 0.055, z), Vector3(0.55, 0.025, 1.2), Color(0.29,0.29,0.28,0.55), 0.98)
	# Driveway edging near the walawwa.
	_box(self, Vector3(-4.15,0.10,18.8), Vector3(0.18,0.16,18.5), Color("6d5c49"))
	_box(self, Vector3(4.15,0.10,18.8), Vector3(0.18,0.16,18.5), Color("6d5c49"))

func _build_paddy_details() -> void:
	var plot_centers: Array[Vector3] = [
		Vector3(-25.0,0.0,-12.0), Vector3(-25.0,0.0,27.0),
		Vector3(24.0,0.0,-14.0), Vector3(24.0,0.0,26.0)
	]
	for p_index: int in range(plot_centers.size()):
		var center: Vector3 = plot_centers[p_index]
		# Mud bunds around crop blocks.
		_box(self, Vector3(center.x,0.10,center.z-14.0), Vector3(21.0,0.20,0.45), Color("776347"))
		_box(self, Vector3(center.x,0.10,center.z+14.0), Vector3(21.0,0.20,0.45), Color("776347"))
		for row: int in range(7):
			var x: float = center.x - 8.0 + float(row) * 2.55
			var root: Node3D = Node3D.new()
			root.position = Vector3(x,0.18,center.z)
			add_child(root)
			wind_nodes.append(root)
			for blade: int in range(4):
				var z_offset: float = -8.5 + float(blade) * 5.6
				var crop: MeshInstance3D = _box(root, Vector3(0.0,0.28,z_offset), Vector3(0.18,0.58,2.6), Color("87a947"))
				crop.rotation_degrees.x = -2.0 + float((row + blade) % 3) * 2.0

func _build_water_details() -> void:
	for i: int in range(11):
		var z: float = -31.0 + float(i) * 6.1
		var glint: MeshInstance3D = _box(self, Vector3(-10.8,0.31,z), Vector3(2.4,0.025,0.13), Color(0.76,0.93,0.96,0.58), 0.18)
		glint.rotation_degrees.y = -8.0 + float(i % 3) * 8.0
		water_glints.append(glint)
	# Reeds along parts of the bank.
	for i: int in range(14):
		var z: float = -29.0 + float(i) * 4.7
		var side_x: float = -8.25 if i % 2 == 0 else -13.25
		var root: Node3D = Node3D.new()
		root.position = Vector3(side_x,0.0,z)
		add_child(root)
		wind_nodes.append(root)
		for j: int in range(3):
			_box(root, Vector3(float(j)*0.12,0.45,float(j)*0.10), Vector3(0.07,0.9,0.07), Color("66864c"))

func _build_walawwa_details() -> void:
	# Stone steps and threshold.
	for i: int in range(3):
		_box(self, Vector3(0.0,0.16+float(i)*0.10,18.25+float(i)*0.58), Vector3(5.8-float(i)*0.7,0.18,0.65), Color("8d8270"))
	# Roof ridge and timber trim.
	_box(self, Vector3(0.0,6.05,29.7), Vector3(0.34,0.34,19.2), Color("5a3027"))
	_box(self, Vector3(-8.85,4.55,29.7), Vector3(0.20,0.20,14.3), Color("4b2d20"))
	_box(self, Vector3(8.85,4.55,29.7), Vector3(0.20,0.20,14.3), Color("4b2d20"))
	# Front planters and shrubs.
	for x: float in [-8.2,-6.8,6.8,8.2]:
		_cylinder(self, Vector3(x,0.35,18.9), 0.42, 0.55, Color("855e43"))
		_sphere(self, Vector3(x,0.95,18.9), 0.72, Color("4f8247"))
	# Warm veranda lamps.
	for x: float in [-4.6,4.6]:
		var lamp_post: MeshInstance3D = _cylinder(self, Vector3(x,3.55,20.25), 0.07, 0.55, Color("4b3426"))
		lamp_post.rotation_degrees.x = 90.0
		_sphere(self, Vector3(x,3.35,20.05), 0.20, Color("ffd99c"), true)

func _build_extra_vegetation() -> void:
	var shrub_positions: Array[Vector3] = [
		Vector3(-11.8,0.0,20.0), Vector3(11.5,0.0,19.5),
		Vector3(-12.5,0.0,34.0), Vector3(12.2,0.0,35.0),
		Vector3(-7.5,0.0,45.0), Vector3(7.8,0.0,44.5)
	]
	for p: Vector3 in shrub_positions:
		var root: Node3D = Node3D.new()
		root.position = p
		add_child(root)
		wind_nodes.append(root)
		_sphere(root, Vector3(0,0.65,0), 0.85, Color("3f7440"))
		_sphere(root, Vector3(0.65,0.55,0.25), 0.55, Color("4d8348"))
		_sphere(root, Vector3(-0.55,0.50,-0.15), 0.50, Color("568c4d"))

func trigger_arrival_dust(world_pos: Vector3) -> void:
	for i: int in range(7):
		var puff: MeshInstance3D = _sphere(self, world_pos + Vector3(-2.0+float(i)*0.65,0.50,1.8+float(i%2)*0.55), 0.40, Color(0.72,0.66,0.55,0.34), true)
		puff.scale = Vector3(1.0,0.55,1.0)
		var tween: Tween = create_tween()
		tween.set_parallel(true)
		tween.tween_property(puff,"position:y",puff.position.y+1.0,1.5)
		tween.tween_property(puff,"scale",Vector3(2.1,1.2,2.1),1.5)
		tween.chain().tween_callback(puff.queue_free)
