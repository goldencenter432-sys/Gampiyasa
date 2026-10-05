extends Node3D

# v0.2.6 mobile-realism layer.
# Adds grounded detail, subtle VFX and material variation without heavy textures.

var earth: Color = Color("665b4a")
var earth_light: Color = Color("81725c")
var grass_dark: Color = Color("42613f")
var grass_mid: Color = Color("58784b")
var stone: Color = Color("696a64")
var wet: Color = Color("3f5352")

func _ready() -> void:
	name = "Realism_v0_2_6"
	_build_road_detail()
	_build_grass_and_field_edges()
	_build_rocks_and_roots()
	_build_walawwa_garden_detail()
	_build_morning_mist()
	_build_ambient_particles()

func _mat(c: Color, roughness: float = 0.92, unshaded: bool = false) -> StandardMaterial3D:
	var m: StandardMaterial3D = StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = roughness
	if unshaded:
		m.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	if c.a < 0.999:
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	return m

func _box(p: Vector3, s: Vector3, c: Color, rot_y: float = 0.0) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: BoxMesh = BoxMesh.new()
	mesh.size = s
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	n.rotation_degrees.y = rot_y
	add_child(n)
	return n

func _cyl(p: Vector3, r: float, h: float, c: Color, sides: int = 8) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: CylinderMesh = CylinderMesh.new()
	mesh.top_radius = r * 0.82
	mesh.bottom_radius = r
	mesh.height = h
	mesh.radial_segments = sides
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	add_child(n)
	return n

func _sphere(p: Vector3, r: float, c: Color) -> MeshInstance3D:
	var n: MeshInstance3D = MeshInstance3D.new()
	var mesh: SphereMesh = SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mesh.radial_segments = 8
	mesh.rings = 4
	mesh.material = _mat(c)
	n.mesh = mesh
	n.position = p
	add_child(n)
	return n

func _build_road_detail() -> void:
	# Broken dirt shoulders, gravel specks and darker compacted wheel lanes.
	for i: int in range(25):
		var z: float = -78.0 + float(i) * 3.55
		var wobble: float = sin(float(i) * 1.73) * 0.42
		var left: MeshInstance3D = _box(Vector3(-3.65 + wobble,0.075,z),Vector3(1.25+float(i%3)*0.18,0.025,2.35),earth_light,-4.0+float(i%4)*2.7)
		left.scale.x = 0.88 + float(i%4)*0.05
		var right: MeshInstance3D = _box(Vector3(3.65 - wobble,0.075,z+0.5),Vector3(1.15+float((i+1)%3)*0.20,0.025,2.15),earth,3.0-float(i%5)*1.4)
		right.scale.x = 0.90 + float(i%3)*0.06
	for lane_x: float in [-1.35,1.35]:
		for j: int in range(15):
			var z2: float = -73.0 + float(j)*5.15
			_box(Vector3(lane_x,0.088,z2),Vector3(0.55,0.012,3.0),Color("55534d"),0.0)
	for k: int in range(44):
		var side: float = -1.0 if k%2==0 else 1.0
		var x: float = side * (3.0 + float((k*7)%13)*0.12)
		var z3: float = -76.0 + float((k*11)%151)
		var pebble: MeshInstance3D = _sphere(Vector3(x,0.14,z3),0.08+float(k%3)*0.025,stone)
		pebble.scale = Vector3(1.3,0.45,0.9)

func _grass_clump(p: Vector3, scale_v: float, color: Color) -> void:
	var root: Node3D = Node3D.new()
	root.position = p
	root.scale = Vector3.ONE * scale_v
	add_child(root)
	for i: int in range(5):
		var blade: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(0.045,0.55+float(i%3)*0.11,0.035)
		mesh.material = _mat(color)
		blade.mesh = mesh
		blade.position = Vector3((-0.16+float(i)*0.08),0.28,float(i%2)*0.08)
		blade.rotation_degrees.z = -12.0+float(i)*6.0
		root.add_child(blade)

func _build_grass_and_field_edges() -> void:
	for i: int in range(34):
		var z: float = -68.0 + float(i)*4.0
		var side: float = -1.0 if i%2==0 else 1.0
		var x: float = side*(5.2+float((i*5)%8)*0.55)
		_grass_clump(Vector3(x,0.08,z),0.75+float(i%4)*0.12,grass_dark if i%3==0 else grass_mid)
	# Paddy bund texture bands.
	for j: int in range(9):
		_box(Vector3(-19.0,0.07,-29.0+float(j)*6.3),Vector3(25.0,0.06,0.34),Color("6f7b46"),float(j%2)*1.3)
		_box(Vector3(20.0,0.07,-31.0+float(j)*6.2),Vector3(27.0,0.06,0.34),Color("73804a"),-float(j%2)*1.2)

func _build_rocks_and_roots() -> void:
	for i: int in range(18):
		var angle: float = float(i)*0.83
		var x: float = -10.0 + float((i*17)%23)
		var z: float = 15.0 + float((i*13)%37)
		var rock: MeshInstance3D = _sphere(Vector3(x,0.20,z),0.22+float(i%4)*0.08,stone)
		rock.scale = Vector3(1.25+0.1*sin(angle),0.55,0.9)
	# Tree-root suggestions near walawwa garden.
	for x2: float in [-7.8,8.2]:
		for r_i: int in range(3):
			var root: MeshInstance3D = _box(Vector3(x2+(-0.7+float(r_i)*0.65),0.10,17.2+float(r_i)*0.35),Vector3(1.65,0.10,0.18),Color("65462f"),-18.0+float(r_i)*16.0)
			root.scale.x = 0.85+float(r_i)*0.08

func _build_walawwa_garden_detail() -> void:
	# Low shrubs and flowers along the veranda approach.
	for i: int in range(12):
		var x: float = -8.5 + float(i)*1.55
		var shrub: MeshInstance3D = _sphere(Vector3(x,0.62,18.7+float(i%2)*0.35),0.55+float(i%3)*0.08,Color("37603b"))
		shrub.scale = Vector3(1.25,0.75,1.0)
		if i%3==0:
			_sphere(Vector3(x+0.16,1.02,18.55),0.10,Color("d7a4a0"))
		if i%4==0:
			_sphere(Vector3(x-0.18,0.96,18.82),0.09,Color("e3c56d"))
	# Worn footpath patches from car to entrance.
	for j: int in range(7):
		_box(Vector3(-0.4+sin(float(j))*0.5,0.09,11.4+float(j)*1.45),Vector3(2.3-float(j%2)*0.35,0.018,1.05),Color("776d58"),float(j%3)*3.0)

func _build_morning_mist() -> void:
	# Thin translucent haze strips in the distant fields.
	for i: int in range(5):
		var n: MeshInstance3D = MeshInstance3D.new()
		var mesh: BoxMesh = BoxMesh.new()
		mesh.size = Vector3(34.0+float(i)*7.0,1.5,0.08)
		mesh.material = _mat(Color(0.84,0.88,0.84,0.09),1.0,true)
		n.mesh = mesh
		n.position = Vector3(-42.0+float(i)*20.0,2.0+float(i%2)*0.5,78.0+float(i)*6.0)
		n.rotation_degrees.y = -7.0+float(i)*3.5
		add_child(n)

func _build_ambient_particles() -> void:
	var particles: GPUParticles3D = GPUParticles3D.new()
	particles.name = "MorningMotes"
	particles.amount = 60
	particles.lifetime = 7.0
	particles.randomness = 0.6
	particles.position = Vector3(0,2.5,20)
	particles.visibility_aabb = AABB(Vector3(-32,-5,-25),Vector3(64,18,70))
	var pm: ParticleProcessMaterial = ParticleProcessMaterial.new()
	pm.emission_shape = ParticleProcessMaterial.EMISSION_SHAPE_BOX
	pm.emission_box_extents = Vector3(25,4,28)
	pm.direction = Vector3(0.35,0.18,0.15)
	pm.spread = 55.0
	pm.gravity = Vector3(0,-0.015,0)
	pm.initial_velocity_min = 0.06
	pm.initial_velocity_max = 0.22
	pm.scale_min = 0.55
	pm.scale_max = 1.15
	pm.color = Color(1.0,0.88,0.64,0.33)
	particles.process_material = pm
	var quad: QuadMesh = QuadMesh.new()
	quad.size = Vector2(0.055,0.055)
	quad.material = _mat(Color(1.0,0.90,0.70,0.38),1.0,true)
	particles.draw_pass_1 = quad
	add_child(particles)
	particles.emitting = true
