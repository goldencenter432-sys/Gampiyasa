extends Node3D

# Gam Piyasa v0.2.5 scenic ring: larger mountains + sunrise focal point.
# Kept procedural and low-poly for mobile performance.

func _ready() -> void:
	name = "Scenery_v0_2_5"
	_build_mountain_ring()
	_build_sunrise_disc()
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
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh.material = _mat(c, unshaded)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func _build_mountain_ring() -> void:
	var specs: Array[Vector4] = [
		Vector4(-78.0, 112.0, 24.0, 1.25),
		Vector4(-48.0, 122.0, 31.0, 1.45),
		Vector4(-15.0, 128.0, 36.0, 1.55),
		Vector4(20.0, 128.0, 35.0, 1.50),
		Vector4(54.0, 121.0, 30.0, 1.40),
		Vector4(82.0, 109.0, 24.0, 1.25),
		Vector4(-112.0, 55.0, 27.0, 1.30),
		Vector4(112.0, 58.0, 28.0, 1.30),
		Vector4(-118.0, -18.0, 25.0, 1.25),
		Vector4(119.0, -12.0, 26.0, 1.25),
		Vector4(-92.0, -92.0, 28.0, 1.30),
		Vector4(94.0, -90.0, 29.0, 1.30)
	]
	for i: int in range(specs.size()):
		var s: Vector4 = specs[i]
		var col: Color = Color("496452") if i < 6 else Color("526b58")
		var mountain: MeshInstance3D = _sphere(self, Vector3(s.x, 7.5, s.y), s.z, col)
		mountain.scale = Vector3(s.w, 0.82 + float(i % 3) * 0.10, 0.72)

	# Distant blue-gray layer for depth.
	for i: int in range(7):
		var x: float = -95.0 + float(i) * 32.0
		var distant: MeshInstance3D = _sphere(self, Vector3(x, 12.0, 154.0 + float(i%2)*6.0), 34.0, Color("6d7f78"))
		distant.scale = Vector3(1.55, 0.86, 0.80)

func _build_sunrise_disc() -> void:
	# Positioned between the central mountain gap and visible from the road/walawwa.
	var sun: MeshInstance3D = _sphere(self, Vector3(3.0, 28.0, 142.0), 5.8, Color("ffd36b"), true)
	sun.scale = Vector3(1.0,1.0,0.35)

	var glow: OmniLight3D = OmniLight3D.new()
	glow.position = Vector3(3.0, 22.0, 105.0)
	glow.light_color = Color("ffcc7a")
	glow.light_energy = 1.5
	glow.omni_range = 50.0
	add_child(glow)

func _build_foreground_ridges() -> void:
	for i: int in range(9):
		var x: float = -82.0 + float(i)*20.5
		var ridge: MeshInstance3D = _sphere(self, Vector3(x,4.0,104.0+float(i%2)*4.0), 15.0, Color("3f5e46"))
		ridge.scale = Vector3(1.35,0.48,0.78)
