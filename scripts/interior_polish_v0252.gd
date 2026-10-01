extends Node3D

# v0.2.5.2 walawwa/interior detail pass.
# Small mobile-friendly props to make rooms read more clearly.

var wood := Color("6b4933")
var dark_wood := Color("463025")
var brass := Color("b18a45")
var cloth := Color("9d765a")
var ceramic := Color("d8d0bf")

func _ready() -> void:
	name = "InteriorPolish_v0_2_5_2"
	_build_veranda_details()
	_build_hall_details()
	_build_kitchen_details()
	_build_bedroom_details()

func _mat(c: Color) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.9
	return m

func _box(parent: Node, p: Vector3, s: Vector3, c: Color) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = s
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func _cylinder(parent: Node, p: Vector3, r: float, h: float, c: Color) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = r
	mesh.bottom_radius = r
	mesh.height = h
	mesh.radial_segments = 10
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func _sphere(parent: Node, p: Vector3, r: float, c: Color) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = r
	mesh.height = r*2.0
	mesh.radial_segments = 10
	mesh.rings = 5
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func _build_veranda_details() -> void:
	# Plank rhythm and welcome mat.
	for i: int in range(10):
		_box(self,Vector3(-8.4+float(i)*1.85,0.58,20.7),Vector3(1.62,0.05,3.25),Color("6f543c"))
	_box(self,Vector3(0.0,0.63,21.25),Vector3(2.8,0.05,1.0),Color("775944"))
	# Two old clay pots.
	for x: float in [-7.9,7.9]:
		_cylinder(self,Vector3(x,0.82,20.9),0.34,0.58,Color("9a5c3d"))
		_sphere(self,Vector3(x,1.28,20.9),0.48,Color("4f7a47"))

func _build_hall_details() -> void:
	# Central woven rug.
	_box(self,Vector3(0.0,0.58,27.4),Vector3(4.8,0.035,2.8),Color("8f684d"))
	_box(self,Vector3(0.0,0.61,27.4),Vector3(4.1,0.02,2.1),Color("b48b65"))
	# Side console with brass lamp.
	_box(self,Vector3(-6.5,1.0,27.6),Vector3(2.0,0.16,0.75),wood)
	for x: float in [-7.25,-5.75]:
		_cylinder(self,Vector3(x,0.55,27.6),0.08,0.9,dark_wood)
	_cylinder(self,Vector3(-6.5,1.55,27.6),0.07,0.8,brass)
	_sphere(self,Vector3(-6.5,1.95,27.6),0.22,Color("e7c47c"))

func _build_kitchen_details() -> void:
	# Plates, bowls and pots on the existing counters.
	for i: int in range(4):
		var x: float = -7.0+float(i)*0.9
		_cylinder(self,Vector3(x,1.78,35.6),0.26,0.08,ceramic)
	for i: int in range(3):
		var z: float = 34.8+float(i)*0.62
		_cylinder(self,Vector3(-4.25,1.72,z),0.30,0.34,Color("4e4c48"))
	# Hanging utensil rail.
	_box(self,Vector3(-5.8,2.85,36.55),Vector3(3.9,0.09,0.09),dark_wood)
	for i: int in range(5):
		var x: float = -7.2+float(i)*0.7
		_cylinder(self,Vector3(x,2.45,36.5),0.04,0.65,Color("76746f"))

func _build_bedroom_details() -> void:
	# Pillow, folded blanket and small bedside lamp.
	_box(self,Vector3(5.55,1.42,36.0),Vector3(1.5,0.18,0.65),Color("e2d9c8"))
	_box(self,Vector3(5.5,1.32,34.65),Vector3(3.0,0.12,0.85),Color("8f6e72"))
	_box(self,Vector3(3.35,0.90,32.45),Vector3(0.9,0.14,0.75),wood)
	_cylinder(self,Vector3(3.35,1.35,32.45),0.06,0.65,brass)
	_sphere(self,Vector3(3.35,1.73,32.45),0.18,Color("e2bd73"))
