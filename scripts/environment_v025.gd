extends Node3D

# Gam Piyasa v0.2.5.1 scenic polish.
# More irregular mountain silhouettes, layered depth and a clearer sunrise gap.

func _ready() -> void:
	name = "Scenery_v0_2_5_1"
	_build_distant_mountains()
	_build_mid_mountain_ring()
	_build_sunrise()
	_build_foreground_ridges()

func _mat(c: Color, unshaded: bool = false) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 1.0
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	return m

func _sphere(parent: Node, p: Vector3, r: float, c: Color, unshaded: bool = false) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mesh.radial_segments = 9
	mesh.rings = 5
	mesh.material = _mat(c, unshaded)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func _mountain_cluster(center: Vector3, base_r: float, color: Color, layer_scale: float) -> void:
	var root: Node3D = Node3D.new()
	root.position = center
	add_child(root)

	# Multiple overlapping low-poly forms create a ridge instead of one smooth blob.
	var pieces: Array[Vector4] = [
		Vector4(-0.85,0.05,0.72,1.10),
		Vector4(-0.38,0.28,0.92,1.22),
		Vector4(0.05,0.52,1.00,1.35),
		Vector4(0.42,0.30,0.88,1.18),
		Vector4(0.82,0.08,0.68,1.05)
	]
	for i: int in range(pieces.size()):
		var p: Vector4 = pieces[i]
		var part: MeshInstance3D = _sphere(root, Vector3(p.x*base_r, p.y*base_r, float(i%2)*1.7), base_r*p.z, color)
		part.scale = Vector3(1.05 + float(i%2)*0.08, p.w*layer_scale, 0.66 + float(i%3)*0.04)

func _build_distant_mountains() -> void:
	var distant: Array[Vector3] = [
		Vector3(-100,8,165),Vector3(-67,10,170),Vector3(-34,12,173),
		Vector3(34,12,173),Vector3(67,10,170),Vector3(100,8,165)
	]
	for i: int in range(distant.size()):
		_mountain_cluster(distant[i], 24.0 + float(i%3)*3.0, Color("6c7f79"), 0.74)

func _build_mid_mountain_ring() -> void:
	var centers: Array[Vector3] = [
		Vector3(-85,5,125),Vector3(-55,6,132),Vector3(-28,7,136),
		# leave a central sunrise gap around x=0
		Vector3(30,7,136),Vector3(58,6,132),Vector3(86,5,124),
		Vector3(-120,4,65),Vector3(120,4,68),
		Vector3(-124,4,-5),Vector3(124,4,-2),
		Vector3(-102,4,-78),Vector3(104,4,-76)
	]
	for i: int in range(centers.size()):
		var col: Color = Color("496552") if i < 6 else Color("536d59")
		_mountain_cluster(centers[i], 20.0 + float(i%4)*2.5, col, 0.82)

func _build_sunrise() -> void:
	var sun: MeshInstance3D = _sphere(self, Vector3(0.0,29.0,147.0), 6.3, Color("ffd36e"), true)
	sun.scale = Vector3(1.0,1.0,0.30)

	# Soft orange halo behind the sun.
	var halo: MeshInstance3D = _sphere(self, Vector3(0.0,28.0,148.5), 10.0, Color(1.0,0.73,0.32,0.24), true)
	var hm: StandardMaterial3D = halo.mesh.material
	hm.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	halo.scale = Vector3(1.15,0.75,0.20)

	var glow: OmniLight3D = OmniLight3D.new()
	glow.position = Vector3(0.0,22.0,95.0)
	glow.light_color = Color("ffbd70")
	glow.light_energy = 2.0
	glow.omni_range = 78.0
	add_child(glow)

func _build_foreground_ridges() -> void:
	for i: int in range(10):
		var x: float = -92.0 + float(i)*20.5
		var ridge: MeshInstance3D = _sphere(self, Vector3(x,3.0,105.0+float(i%2)*4.0), 14.0, Color("3f5f47"))
		ridge.scale = Vector3(1.30,0.42,0.72)
