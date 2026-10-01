extends Node3D

# Gam Piyasa v0.2.5.2 scenic polish.
# Sharper layered mountains, a clearer sunrise gap, and warmer dawn lighting.

func _ready() -> void:
	name = "Scenery_v0_2_5_2"
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
	if c.a < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _sphere(parent: Node, p: Vector3, r: float, c: Color, unshaded: bool = false) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mesh.radial_segments = 10
	mesh.rings = 5
	mesh.material = _mat(c, unshaded)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func _cone(parent: Node, p: Vector3, radius: float, height: float, c: Color, sides: int = 7) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = 0.0
	mesh.bottom_radius = radius
	mesh.height = height
	mesh.radial_segments = sides
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func _mountain_ridge(center: Vector3, base_r: float, base_h: float, color: Color, depth_scale: float) -> void:
	var root: Node3D = Node3D.new()
	root.position = center
	add_child(root)

	# Pointed overlapping peaks produce a stronger Sri Lankan hill-country silhouette.
	var offsets: Array[Vector3] = [
		Vector3(-1.45,0.00,0.0),
		Vector3(-0.82,0.05,1.6),
		Vector3(-0.28,0.08,-0.8),
		Vector3(0.32,0.10,1.2),
		Vector3(0.90,0.04,-0.6),
		Vector3(1.48,0.00,1.0)
	]
	for i: int in range(offsets.size()):
		var off: Vector3 = offsets[i]
		var height_mul: float = 0.66 + float((i * 5 + 2) % 7) * 0.075
		var radius_mul: float = 0.72 + float((i * 2 + 1) % 5) * 0.07
		var peak: MeshInstance3D = _cone(
			root,
			Vector3(off.x * base_r * 0.72, base_h * height_mul * 0.48, off.z),
			base_r * radius_mul,
			base_h * height_mul,
			color,
			6 + (i % 3)
		)
		peak.scale = Vector3(0.82 + float((i*3)%5)*0.08, 1.0, depth_scale * (0.82 + float((i*4)%5)*0.06))
		peak.rotation_degrees.y = -18.0 + float(i)*6.3
		peak.rotation_degrees.z = -4.5 + float((i*3)%7)*1.3

	# Low rounded foot-hills merge the pointed peaks into one ridge.
	for j: int in range(4):
		var foot: MeshInstance3D = _sphere(
			root,
			Vector3((-1.10 + float(j)*0.72)*base_r, 1.8, 2.0 + float(j%2)*1.6),
			base_r*0.70,
			color
		)
		foot.scale = Vector3(1.15,0.30,depth_scale)

func _build_distant_mountains() -> void:
	var distant: Array[Vector3] = [
		Vector3(-104,0,169),Vector3(-72,0,174),Vector3(-40,0,177),
		Vector3(40,0,177),Vector3(72,0,174),Vector3(104,0,169)
	]
	for i: int in range(distant.size()):
		_mountain_ridge(
			distant[i],
			18.0 + float(i%3)*2.0,
			38.0 + float(i%2)*5.0,
			Color("73837f"),
			0.68
		)

func _build_mid_mountain_ring() -> void:
	var centers: Array[Vector3] = [
		Vector3(-91,0,126),Vector3(-62,0,134),Vector3(-35,0,139),
		# Deliberate central gap for sunrise.
		Vector3(36,0,139),Vector3(63,0,134),Vector3(92,0,126),
		Vector3(-122,0,70),Vector3(123,0,72),
		Vector3(-127,0,2),Vector3(127,0,5),
		Vector3(-108,0,-76),Vector3(109,0,-74)
	]
	for i: int in range(centers.size()):
		var col: Color = Color("47624f") if i < 6 else Color("506b57")
		_mountain_ridge(
			centers[i],
			16.5 + float(i%4)*1.9,
			31.0 + float(i%3)*4.0,
			col,
			0.72
		)

func _build_sunrise() -> void:
	# Large sun placed in the intentional mountain gap.
	var sun: MeshInstance3D = _sphere(self, Vector3(0.0,31.5,145.0), 7.0, Color("ffc55f"), true)
	sun.scale = Vector3(1.0,1.0,0.28)

	var halo: MeshInstance3D = _sphere(self, Vector3(0.0,33.0,146.5), 13.0, Color(1.0,0.54,0.16,0.26), true)
	halo.scale = Vector3(1.10,0.72,0.18)

	var glow: OmniLight3D = OmniLight3D.new()
	glow.position = Vector3(0.0,24.0,92.0)
	glow.light_color = Color("ffb96a")
	glow.light_energy = 2.4
	glow.omni_range = 86.0
	add_child(glow)

func _build_foreground_ridges() -> void:
	# Darker low ridges add parallax and stop the horizon looking flat.
	for i: int in range(10):
		var x: float = -94.0 + float(i)*20.8
		var ridge: MeshInstance3D = _cone(self, Vector3(x,8.0,106.0+float(i%2)*4.5), 15.0, 20.0+float(i%3)*3.0, Color("465c4a"), 7)
		ridge.scale.z = 0.70
