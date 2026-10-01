extends Node3D

const MobileControls = preload("res://scripts/mobile_controls.gd")
const EnvironmentV021 = preload("res://scripts/environment_v021.gd")
const VisualsV022 = preload("res://scripts/visuals_v022.gd")
const ContentV024 = preload("res://scripts/content_v024.gd")
const EnvironmentV025 = preload("res://scripts/environment_v025.gd")
const InteriorPolishV0252 = preload("res://scripts/interior_polish_v0252.gd")
enum GameState { DRIVE, ARRIVAL, DIALOGUE, PLAY }

var state := GameState.DRIVE
var clock := 0.0
var car: Node3D
var family: Node3D
var grandma: Node3D
var visuals_v022: Node3D
var content_v024: Node3D
var scenery_v025: Node3D
var interior_polish_v0252: Node3D
var father: Node3D
var mother: Node3D
var daughter: Node3D
var cutscene_boy: Node3D
var car_door_fl: Node3D
var car_door_fr: Node3D
var car_door_rl: Node3D
var car_door_rr: Node3D
var front_door_left: Node3D
var front_door_right: Node3D
var player: CharacterBody3D
var body_visual: Node3D
var pivot: Node3D
var play_cam: Camera3D
var cine_cam: Camera3D
var controls: Control
var dialogue: Label
var dialogue_panel: ColorRect
var objective: Label
var objective_panel: ColorRect
var jump_btn: Button
var interact_btn: Button
var skip_btn: Button
var yaw := 0.0
var pitch := -0.15
var jump_request := false
var engine: AudioStreamPlayer3D
var ambience: AudioStreamPlayer
var step_sound: AudioStreamPlayer3D
var step_timer := 0.0
var cine_stage := 0
var drive_a := Vector3(0,0.43,-79.0)
var drive_b := Vector3(0,0.43,8.0)

func _ready() -> void:
	build_world()
	var environment_v021: Node3D = EnvironmentV021.new()
	add_child(environment_v021)
	front_door_left = environment_v021.find_child("FrontDoorLeft", true, false) as Node3D
	front_door_right = environment_v021.find_child("FrontDoorRight", true, false) as Node3D
	visuals_v022 = VisualsV022.new()
	add_child(visuals_v022)
	content_v024 = ContentV024.new()
	add_child(content_v024)
	scenery_v025 = EnvironmentV025.new()
	add_child(scenery_v025)
	interior_polish_v0252 = InteriorPolishV0252.new()
	add_child(interior_polish_v0252)
	build_people_and_car()
	build_player()
	build_ui()
	build_audio()
	start_cutscene()

func material(c: Color) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = 0.88
	return m

func box(parent: Node, p: Vector3, s: Vector3, c: Color, collide := false) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = s
	mesh.material = material(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	if collide:
		var b := StaticBody3D.new()
		var cs := CollisionShape3D.new()
		var sh := BoxShape3D.new()
		sh.size = s
		cs.shape = sh
		b.add_child(cs)
		n.add_child(b)
	return n

func sphere(parent: Node, p: Vector3, r: float, c: Color) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := SphereMesh.new()
	mesh.radius = r
	mesh.height = r * 2.0
	mesh.radial_segments = 12
	mesh.rings = 6
	mesh.material = material(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func cylinder(parent: Node, p: Vector3, r: float, h: float, c: Color) -> MeshInstance3D:
	var n := MeshInstance3D.new()
	var mesh := CylinderMesh.new()
	mesh.top_radius = r
	mesh.bottom_radius = r
	mesh.height = h
	mesh.radial_segments = 12
	mesh.material = material(c)
	n.mesh = mesh
	n.position = p
	parent.add_child(n)
	return n

func build_world() -> void:
	var we := WorldEnvironment.new()
	var e := Environment.new()
	e.background_mode = Environment.BG_SKY
	var sky := Sky.new()
	var sm := ProceduralSkyMaterial.new()
	sm.sky_top_color = Color("3f83c8")
	sm.sky_horizon_color = Color("d5edf7")
	sm.ground_bottom_color = Color("496844")
	sm.ground_horizon_color = Color("b8c895")
	sm.sun_angle_max = 18.0
	sky.sky_material = sm
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.95
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_density = 0.0022
	e.fog_light_color = Color("d8e9ed")
	e.fog_light_energy = 0.65
	we.environment = e
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-52,-32,0)
	sun.light_color = Color("fff2d1")
	sun.light_energy = 1.18
	sun.shadow_enabled = true
	sun.directional_shadow_max_distance = 70.0
	add_child(sun)

func build_village() -> void:
	box(self, Vector3(0,-0.3,12), Vector3(92,0.5,112), Color("6f9d52"), true)
	box(self, Vector3(0,0,-8), Vector3(7,0.12,64), Color("5d5c59"))
	box(self, Vector3(0,0.03,20), Vector3(8,0.1,12), Color("907c60"))
	box(self, Vector3(-18,-0.02,0), Vector3(24,0.07,55), Color("8eae45"))
	box(self, Vector3(19,-0.02,-2), Vector3(25,0.07,52), Color("9bb74e"))
	box(self, Vector3(-6.5,0.02,-7), Vector3(1.4,0.05,60), Color("4e90a4"))
	var trees = [Vector3(-9,0,18),Vector3(9,0,16),Vector3(-12,0,30),Vector3(12,0,31),Vector3(-16,0,-12),Vector3(16,0,-20),Vector3(-20,0,8),Vector3(20,0,10)]
	for p in trees:
		make_tree(p)
	for i in range(8):
		var h := sphere(self, Vector3(-31+i*9,2.5,58+(i%2)*4), 8.5, Color("557a4c"))
		h.scale = Vector3(1.7,0.55,1)

func make_tree(p: Vector3) -> void:
	var n := Node3D.new()
	n.position = p
	add_child(n)
	cylinder(n, Vector3(0,1.6,0), 0.32, 3.2, Color("704b2f"))
	sphere(n, Vector3(0,3.9,0), 2.0, Color("2e6b3c"))
	sphere(n, Vector3(-1,3.6,0.4), 1.35, Color("3d7b45"))
	sphere(n, Vector3(1,3.7,-0.3), 1.4, Color("397541"))

func build_house() -> void:
	var h := Node3D.new()
	h.position = Vector3.ZERO
	add_child(h)
	var wall := Color("e8dec5")
	box(h,Vector3(0,0.15,29),Vector3(15,0.35,11),Color("bba98c"),true)
	box(h,Vector3(0,0.4,29),Vector3(13.6,0.12,9.6),Color("714d31"))
	box(h,Vector3(-7,2.3,29),Vector3(0.4,4,10),wall,true)
	box(h,Vector3(7,2.3,29),Vector3(0.4,4,10),wall,true)
	box(h,Vector3(0,2.3,34),Vector3(14,4,0.4),wall,true)
	box(h,Vector3(-4.2,2.3,24),Vector3(5.6,4,0.4),wall,true)
	box(h,Vector3(4.2,2.3,24),Vector3(5.6,4,0.4),wall,true)
	box(h,Vector3(0,3.6,24),Vector3(2.8,1.4,0.4),wall,true)
	box(h,Vector3(0,0.4,22.8),Vector3(15,0.25,2.2),Color("896544"),true)
	for x in [-6.2,-3.1,3.1,6.2]:
		cylinder(h,Vector3(x,2.1,22.6),0.18,3.4,Color("efe1c4"))
	var rl := box(h,Vector3(-3.7,4.8,29),Vector3(8.5,0.35,12),Color("8d3f30"))
	rl.rotation_degrees.z = -18
	var rr := box(h,Vector3(3.7,4.8,29),Vector3(8.5,0.35,12),Color("984433"))
	rr.rotation_degrees.z = 18
	box(h,Vector3(0,0.2,21.6),Vector3(4,0.25,0.9),Color("9e9078"),true)
	box(h,Vector3(-3.6,1.2,30),Vector3(3.2,0.18,1.7),Color("5d3b26"),true)
	box(h,Vector3(4.8,1.3,32.8),Vector3(2.2,2.1,0.7),Color("60422c"),true)
	box(h,Vector3(3.5,0.8,28),Vector3(3.4,0.55,1),Color("7d5536"),true)
	for lx in [-3.5,3.5]:
		var light := OmniLight3D.new()
		light.position = Vector3(lx,3.1,29)
		light.light_color = Color("ffd7a5")
		light.light_energy = 2.0
		light.omni_range = 7
		h.add_child(light)

func person(parent: Node, p: Vector3, cloth: Color, scale_v := 1.0) -> Node3D:
	var n := Node3D.new()
	n.position = p
	n.scale = Vector3.ONE * scale_v
	parent.add_child(n)
	cylinder(n,Vector3(0,1.15,0),0.38,1.45,cloth)
	sphere(n,Vector3(0,2.1,0),0.34,Color("d3a07d"))
	cylinder(n,Vector3(-0.16,0.35,0),0.1,0.7,Color("383635"))
	cylinder(n,Vector3(0.16,0.35,0),0.1,0.7,Color("383635"))
	cylinder(n,Vector3(-0.48,1.18,0),0.09,0.82,Color("d3a07d"))
	cylinder(n,Vector3(0.48,1.18,0),0.09,0.82,Color("d3a07d"))
	return n

func build_child(parent: Node, p: Vector3, shirt: Color, scale_v: float = 1.0) -> Node3D:
	var n: Node3D = Node3D.new()
	n.position = p
	n.scale = Vector3.ONE * scale_v
	parent.add_child(n)
	# More natural child silhouette: torso, head, arms, shorts and separated legs.
	box(n,Vector3(0,1.20,0),Vector3(0.72,0.95,0.42),shirt)
	sphere(n,Vector3(0,1.95,0),0.31,Color("d3a07d"))
	# Hair cap.
	var hair: MeshInstance3D = sphere(n,Vector3(0,2.12,0.02),0.30,Color("2b211c"))
	hair.scale = Vector3(1.02,0.55,1.0)
	# Arms.
	cylinder(n,Vector3(-0.46,1.18,0),0.09,0.82,Color("d3a07d"))
	cylinder(n,Vector3(0.46,1.18,0),0.09,0.82,Color("d3a07d"))
	# Shorts + legs.
	box(n,Vector3(0,0.70,0),Vector3(0.70,0.38,0.44),Color("3f4f67"))
	cylinder(n,Vector3(-0.20,0.28,0),0.10,0.72,Color("b98568"))
	cylinder(n,Vector3(0.20,0.28,0),0.10,0.72,Color("b98568"))
	# Shoes.
	box(n,Vector3(-0.20,-0.09,-0.06),Vector3(0.25,0.14,0.42),Color("2f2f2f"))
	box(n,Vector3(0.20,-0.09,-0.06),Vector3(0.25,0.14,0.42),Color("2f2f2f"))
	return n

func animate_walk_pose(n: Node3D, phase: float, amount: float, child_model: bool = false) -> void:
	var swing: float = sin(phase) * 26.0 * amount
	if child_model:
		if n.get_child_count() >= 8:
			var arm_l: Node3D = n.get_child(3) as Node3D
			var arm_r: Node3D = n.get_child(4) as Node3D
			var leg_l: Node3D = n.get_child(6) as Node3D
			var leg_r: Node3D = n.get_child(7) as Node3D
			arm_l.rotation_degrees.x = swing
			arm_r.rotation_degrees.x = -swing
			leg_l.rotation_degrees.x = -swing * 0.65
			leg_r.rotation_degrees.x = swing * 0.65
	else:
		if n.get_child_count() >= 6:
			var leg_l: Node3D = n.get_child(2) as Node3D
			var leg_r: Node3D = n.get_child(3) as Node3D
			var arm_l: Node3D = n.get_child(4) as Node3D
			var arm_r: Node3D = n.get_child(5) as Node3D
			leg_l.rotation_degrees.x = -swing * 0.65
			leg_r.rotation_degrees.x = swing * 0.65
			arm_l.rotation_degrees.x = swing
			arm_r.rotation_degrees.x = -swing

func update_third_person_camera() -> void:
	var origin: Vector3 = pivot.global_position + Vector3(0.0,0.35,0.0)
	var desired_local: Vector3 = Vector3(0.55,1.45,3.85)
	var desired_global: Vector3 = pivot.to_global(desired_local)
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(origin, desired_global)
	query.exclude = [player.get_rid()]
	var hit: Dictionary = get_world_3d().direct_space_state.intersect_ray(query)
	if hit.has("position"):
		var hit_pos: Vector3 = hit["position"]
		var back_dir: Vector3 = (origin - hit_pos).normalized()
		play_cam.global_position = hit_pos + back_dir * 0.28
	else:
		play_cam.position = play_cam.position.lerp(desired_local,0.18)

func build_grandma(p: Vector3) -> Node3D:
	var n: Node3D = Node3D.new()
	n.name = "Grandma_v0_2_5"
	n.position = p
	n.scale = Vector3.ONE * 0.92
	add_child(n)
	# Elderly body proportions and traditional warm clothing.
	cylinder(n,Vector3(0,1.05,0),0.42,1.35,Color("d7cbb1"))
	box(n,Vector3(0,1.08,0.06),Vector3(0.92,1.15,0.20),Color("8e657f"))
	sphere(n,Vector3(0,2.02,0),0.36,Color("c99a78"))
	# Grey hair cap + bun.
	sphere(n,Vector3(0,2.22,0.05),0.34,Color("c9c7c0"))
	sphere(n,Vector3(0.0,2.23,0.34),0.20,Color("b7b5af"))
	# Arms and legs.
	cylinder(n,Vector3(-0.46,1.12,0),0.10,0.92,Color("c99a78"))
	cylinder(n,Vector3(0.46,1.12,0),0.10,0.92,Color("c99a78"))
	cylinder(n,Vector3(-0.17,0.34,0),0.10,0.65,Color("4f4944"))
	cylinder(n,Vector3(0.17,0.34,0),0.10,0.65,Color("4f4944"))
	# Small shawl/sari accent so she reads clearly from the arrival camera.
	var shawl: MeshInstance3D = box(n,Vector3(0.16,1.35,-0.24),Vector3(0.42,1.15,0.12),Color("7d5973"))
	shawl.rotation_degrees.z = -10.0
	return n

func build_people_and_car() -> void:
	car = Node3D.new()
	car.name = "FamilyCar_v0_2_2"
	car.position = drive_a
	add_child(car)

	var body_color: Color = Color("294f5f")
	var body_light: Color = Color("3f6875")
	var chrome: Color = Color("b6b4ac")
	var glass: Color = Color("38535c")

	# More detailed classic family car silhouette.
	box(car, Vector3(0,0.62,0), Vector3(2.50,0.66,4.65), body_color)
	box(car, Vector3(0,0.98,-1.55), Vector3(2.35,0.36,1.45), body_light)
	box(car, Vector3(0,1.15,1.50), Vector3(2.30,0.42,1.20), body_color)
	box(car, Vector3(0,1.42,0.05), Vector3(2.05,0.88,2.25), body_light)

	var windshield: MeshInstance3D = box(car, Vector3(0,1.62,-1.05), Vector3(1.84,0.64,0.10), glass)
	windshield.rotation_degrees.x = -16.0
	var rear_window: MeshInstance3D = box(car, Vector3(0,1.62,1.12), Vector3(1.80,0.58,0.10), glass)
	rear_window.rotation_degrees.x = 14.0
	box(car, Vector3(-1.03,1.52,0.02), Vector3(0.08,0.62,1.45), glass)
	box(car, Vector3(1.03,1.52,0.02), Vector3(0.08,0.62,1.45), glass)

	# Bumpers, grille and lamps.
	box(car, Vector3(0,0.55,-2.38), Vector3(2.58,0.15,0.16), chrome)
	box(car, Vector3(0,0.55,2.38), Vector3(2.58,0.15,0.16), chrome)
	box(car, Vector3(0,0.82,-2.36), Vector3(1.10,0.32,0.09), Color("22272a"))
	sphere(car, Vector3(-0.78,0.86,-2.34), 0.18, Color("f1e2b3"))
	sphere(car, Vector3(0.78,0.86,-2.34), 0.18, Color("f1e2b3"))
	sphere(car, Vector3(-0.82,0.84,2.34), 0.15, Color("9f342e"))
	sphere(car, Vector3(0.82,0.84,2.34), 0.15, Color("9f342e"))

	var wheel_xs: Array[float] = [-1.20, 1.20]
	var wheel_zs: Array[float] = [-1.55, 1.55]
	for x: float in wheel_xs:
		for z: float in wheel_zs:
			var wheel: MeshInstance3D = cylinder(car, Vector3(x,0.38,z), 0.43, 0.32, Color("171717"))
			wheel.rotation_degrees.z = 90.0
			var hub: MeshInstance3D = cylinder(car, Vector3(x,0.38,z), 0.20, 0.34, chrome)
			hub.rotation_degrees.z = 90.0

	# Side mirrors.
	box(car, Vector3(-1.34,1.46,-0.85), Vector3(0.22,0.16,0.28), chrome)
	box(car, Vector3(1.34,1.46,-0.85), Vector3(0.22,0.16,0.28), chrome)

	# Hinged car-door visuals used by the arrival animation.
	car_door_fl = Node3D.new()
	car_door_fl.position = Vector3(-1.25,1.08,-0.95)
	car.add_child(car_door_fl)
	box(car_door_fl,Vector3(0,0,0),Vector3(0.10,1.25,1.15),body_color)
	car_door_fr = Node3D.new()
	car_door_fr.position = Vector3(1.25,1.08,-0.95)
	car.add_child(car_door_fr)
	box(car_door_fr,Vector3(0,0,0),Vector3(0.10,1.25,1.15),body_color)
	car_door_rl = Node3D.new()
	car_door_rl.position = Vector3(-1.25,1.08,0.85)
	car.add_child(car_door_rl)
	box(car_door_rl,Vector3(0,0,0),Vector3(0.10,1.25,1.15),body_color)
	car_door_rr = Node3D.new()
	car_door_rr.position = Vector3(1.25,1.08,0.85)
	car.add_child(car_door_rr)
	box(car_door_rr,Vector3(0,0,0),Vector3(0.10,1.25,1.15),body_color)

	family = Node3D.new()
	family.visible = false
	add_child(family)
	father = person(family,Vector3(-1.45,0,7.4),Color("526d8b"))
	father.name = "Father"
	mother = person(family,Vector3(1.45,0,7.2),Color("9b617c"),0.95)
	mother.name = "Mother"
	daughter = person(family,Vector3(1.65,0,8.7),Color("d19d44"),0.78)
	daughter.name = "Daughter"
	cutscene_boy = build_child(family,Vector3(-1.55,0,8.7),Color("4b76a5"),0.78)
	cutscene_boy.name = "BoyCutscene"

	grandma = build_grandma(Vector3(0.0,0,28.6))
	grandma.visible = true

func build_player() -> void:
	player = CharacterBody3D.new()
	player.position = Vector3(0,1.05,17.4)
	add_child(player)
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.38
	cap.height = 1.55
	cs.shape = cap
	player.add_child(cs)
	body_visual = build_child(player,Vector3(0,-0.98,0),Color("4b76a5"),0.78)
	pivot = Node3D.new()
	player.add_child(pivot)
	pivot.position = Vector3(0,1.2,0)
	play_cam = Camera3D.new()
	play_cam.position = Vector3(0.55,1.45,3.85)
	play_cam.rotation_degrees.x = -7.0
	play_cam.fov = 70.0
	pivot.add_child(play_cam)
	cine_cam = Camera3D.new()
	add_child(cine_cam)
	player.visible = false

func build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	controls = MobileControls.new()
	controls.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.add_child(controls)
	controls.set_active(false)
	objective_panel = ColorRect.new()
	objective_panel.position = Vector2(18,16)
	objective_panel.size = Vector2(610,52)
	objective_panel.color = Color(0.02,0.03,0.04,0.58)
	layer.add_child(objective_panel)
	objective = Label.new()
	objective.position = Vector2(30,27)
	objective.size = Vector2(585,36)
	objective.add_theme_font_size_override("font_size",21)
	objective.add_theme_color_override("font_color",Color("fff4df"))
	objective.text = "ගමට යන ගමන්...  •  v0.2.5.2"
	layer.add_child(objective)

	dialogue_panel = ColorRect.new()
	dialogue_panel.position = Vector2(115,552)
	dialogue_panel.size = Vector2(1010,92)
	dialogue_panel.color = Color(0.02,0.02,0.025,0.72)
	dialogue_panel.visible = false
	layer.add_child(dialogue_panel)
	dialogue = Label.new()
	dialogue.position = Vector2(145,562)
	dialogue.size = Vector2(950,72)
	dialogue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialogue.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dialogue.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	dialogue.add_theme_font_size_override("font_size",26)
	dialogue.add_theme_color_override("font_color",Color.WHITE)
	dialogue.add_theme_color_override("font_shadow_color",Color(0,0,0,0.8))
	dialogue.add_theme_constant_override("shadow_offset_x",2)
	dialogue.add_theme_constant_override("shadow_offset_y",2)
	dialogue.visible = false
	dialogue_panel.visible = false
	layer.add_child(dialogue)
	jump_btn = Button.new()
	jump_btn.text = "JUMP"
	jump_btn.position = Vector2(1110,560)
	jump_btn.size = Vector2(130,70)
	jump_btn.visible = false
	jump_btn.pressed.connect(func(): jump_request = true)
	layer.add_child(jump_btn)
	interact_btn = Button.new()
	interact_btn.text = "INTERACT"
	interact_btn.position = Vector2(955,625)
	interact_btn.size = Vector2(150,70)
	interact_btn.visible = false
	interact_btn.pressed.connect(on_interact)
	layer.add_child(interact_btn)
	skip_btn = Button.new()
	skip_btn.text = "SKIP"
	skip_btn.position = Vector2(1120,30)
	skip_btn.size = Vector2(110,55)
	skip_btn.pressed.connect(begin_play)
	layer.add_child(skip_btn)

func make_wav(freq: float, seconds: float, noise := false) -> AudioStreamWAV:
	var rate := 22050
	var count := int(rate * seconds)
	var data := PackedByteArray()
	data.resize(count * 2)
	for i in range(count):
		var t := float(i) / rate
		var v := sin(TAU * freq * t)
		if noise:
			v = randf_range(-1.0,1.0) * exp(-8.0*t)
		var sample := int(clamp(v * 7000.0,-32767.0,32767.0))
		data.encode_s16(i*2,sample)
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	return wav

func build_audio() -> void:
	ambience = AudioStreamPlayer.new()
	var birds := make_wav(1450,0.7)
	birds.loop_mode = AudioStreamWAV.LOOP_FORWARD
	ambience.stream = birds
	ambience.volume_db = -22
	add_child(ambience)
	ambience.play()
	engine = AudioStreamPlayer3D.new()
	var eng := make_wav(95,1.2)
	eng.loop_mode = AudioStreamWAV.LOOP_FORWARD
	engine.stream = eng
	engine.volume_db = -13
	car.add_child(engine)
	step_sound = AudioStreamPlayer3D.new()
	step_sound.stream = make_wav(80,0.12,true)
	step_sound.volume_db = -10
	player.add_child(step_sound)

func start_cutscene() -> void:
	state = GameState.DRIVE
	clock = 0
	cine_stage = 0
	cine_cam.current = true
	play_cam.current = false
	engine.play()

func _process(delta: float) -> void:
	clock += delta
	if state == GameState.DRIVE:
		var t: float = clampf(clock / 18.0, 0.0, 1.0)
		car.position = drive_a.lerp(drive_b, smoothstep(0.0, 1.0, t))

		# v0.2.4 four-shot intro: road chase -> field panorama -> canal side -> walawwa approach.
		if t < 0.25:
			cine_stage = 0
			var shot_t: float = t / 0.25
			cine_cam.global_position = car.global_position + Vector3(5.4, 2.0, -7.8 + shot_t * 1.6)
			cine_cam.look_at(car.global_position + Vector3(0, 0.9, 2.2), Vector3.UP)
		elif t < 0.50:
			cine_stage = 1
			var field_t: float = (t - 0.25) / 0.25
			cine_cam.global_position = car.global_position + Vector3(-11.0 + field_t * 2.0, 7.8, -2.5)
			cine_cam.look_at(car.global_position + Vector3(0, 0.7, 5.0), Vector3.UP)
		elif t < 0.74:
			cine_stage = 2
			var canal_t: float = (t - 0.50) / 0.24
			cine_cam.global_position = car.global_position + Vector3(-7.5, 2.8 + canal_t * 1.2, -4.0)
			cine_cam.look_at(car.global_position + Vector3(0, 0.8, 3.0), Vector3.UP)
		else:
			cine_stage = 3
			var arrival_t: float = (t - 0.74) / 0.26
			cine_cam.global_position = Vector3(8.5 - arrival_t * 3.0, 4.2 + arrival_t * 0.5, 1.0 + arrival_t * 8.0)
			cine_cam.look_at(car.global_position + Vector3(0, 0.9, 1.0), Vector3.UP)

		if t >= 1.0:
			state = GameState.ARRIVAL
			clock = 0.0
			cine_stage = 0
			family.visible = true
			father.visible = false
			mother.visible = false
			daughter.visible = false
			cutscene_boy.visible = false
			grandma.visible = true
			grandma.position = Vector3(0.0,0,28.6)
			engine.stop()
			if visuals_v022 != null and visuals_v022.has_method("trigger_arrival_dust"):
				visuals_v022.call("trigger_arrival_dust", car.global_position)
			objective.text = "ආච්චිලාගේ ගෙදරට ආවා"
	elif state == GameState.ARRIVAL:
		# Full family exit + grandma house-exit animation.
		var parked: Vector3 = car.global_position
		grandma.visible = true

		# 0-2.5 sec: establish parked car + walawwa.
		if clock < 2.5:
			cine_cam.global_position = Vector3(12.8,5.8,8.5)
			cine_cam.look_at(Vector3(0.0,2.0,22.0),Vector3.UP)

		# 2.5-8.5 sec: open doors and animate family stepping out.
		elif clock < 8.0:
			var exit_t: float = clampf((clock-2.5)/5.5,0.0,1.0)
			cine_cam.global_position = Vector3(9.2,3.5,6.2)
			cine_cam.look_at(parked + Vector3(0,1.1,0.8),Vector3.UP)

			car_door_fl.rotation_degrees.y = lerpf(0.0,-58.0,clampf(exit_t*3.0,0.0,1.0))
			car_door_fr.rotation_degrees.y = lerpf(0.0,58.0,clampf(exit_t*3.0,0.0,1.0))
			car_door_rl.rotation_degrees.y = lerpf(0.0,-62.0,clampf((exit_t-0.16)*3.0,0.0,1.0))
			car_door_rr.rotation_degrees.y = lerpf(0.0,62.0,clampf((exit_t-0.16)*3.0,0.0,1.0))

			if exit_t > 0.08:
				father.visible = true
				var ft: float = clampf((exit_t-0.08)/0.30,0.0,1.0)
				father.global_position = parked + Vector3(-1.2,0.10 + sin(ft*PI)*0.10,-0.9).lerp(Vector3(-2.5,0.0,-0.7),smoothstep(0.0,1.0,ft))
				animate_walk_pose(father,ft*TAU*1.3,1.0,false)
			if exit_t > 0.20:
				mother.visible = true
				var mt: float = clampf((exit_t-0.20)/0.30,0.0,1.0)
				mother.global_position = parked + Vector3(1.2,0.10 + sin(mt*PI)*0.10,-0.8).lerp(Vector3(2.5,0.0,-0.5),smoothstep(0.0,1.0,mt))
				animate_walk_pose(mother,mt*TAU*1.3,0.9,false)
			if exit_t > 0.36:
				daughter.visible = true
				var dt: float = clampf((exit_t-0.36)/0.28,0.0,1.0)
				daughter.global_position = parked + Vector3(1.2,0.08 + sin(dt*PI)*0.08,0.9).lerp(Vector3(2.8,0.0,1.2),smoothstep(0.0,1.0,dt))
				animate_walk_pose(daughter,dt*TAU*1.35,0.85,false)
			if exit_t > 0.50:
				cutscene_boy.visible = true
				var bt: float = clampf((exit_t-0.50)/0.26,0.0,1.0)
				cutscene_boy.global_position = parked + Vector3(-1.2,0.08 + sin(bt*PI)*0.08,0.9).lerp(Vector3(-2.6,0.0,1.4),smoothstep(0.0,1.0,bt))
				cutscene_boy.rotation_degrees.y = lerpf(0.0,-18.0,bt)
				animate_walk_pose(cutscene_boy,bt*TAU*1.45,1.0,true)

		# 8.5-13 sec: grandma walks from inside to the veranda.
		elif clock < 12.3:
			var gt: float = clampf((clock-8.0)/4.3,0.0,1.0)
			var door_t: float = clampf(gt/0.34,0.0,1.0)
			if front_door_left != null:
				front_door_left.rotation_degrees.y = lerpf(0.0,-42.0,smoothstep(0.0,1.0,door_t))
			if front_door_right != null:
				front_door_right.rotation_degrees.y = lerpf(0.0,42.0,smoothstep(0.0,1.0,door_t))
			var walk_t: float = clampf((gt-0.18)/0.82,0.0,1.0)
			grandma.position = Vector3(0.0,0.0,28.6).lerp(Vector3(-2.2,0.0,20.7),smoothstep(0.0,1.0,walk_t))
			grandma.position.y = sin(walk_t*PI*4.0)*0.035
			grandma.rotation_degrees.y = lerpf(180.0,0.0,walk_t)
			grandma.rotation_degrees.z = sin(walk_t*TAU*2.0)*1.2
			cine_cam.global_position = Vector3(-10.5,3.8,15.4)
			cine_cam.look_at(grandma.global_position + Vector3(0,1.4,0),Vector3.UP)

		# 13-16 sec: family + grandma hero shot before dialogue.
		else:
			if front_door_left != null:
				front_door_left.rotation_degrees.y = -42.0
			if front_door_right != null:
				front_door_right.rotation_degrees.y = 42.0
			grandma.position = Vector3(-2.2,0.0,20.7)
			cine_cam.global_position = Vector3(9.5,4.6,13.2)
			cine_cam.look_at(Vector3(-0.5,1.5,20.0),Vector3.UP)

		if clock > 15.0:
			state = GameState.DIALOGUE
			clock = 0.0
			dialogue_panel.visible = true
			dialogue.visible = true
			dialogue.text = "ආච්චි: ආ මේ ළමයිනේ! එන්න ඇතුළට. ගොඩ කාලෙකින් ඔයාලව දැක්කෙ."
	elif state == GameState.DIALOGUE:
		cine_cam.global_position = Vector3(8.8,3.6,14.6)
		cine_cam.look_at(grandma.global_position + Vector3(0,1.3,0),Vector3.UP)
		if clock > 4.0 and clock <= 7.5:
			dialogue.text = "අම්මා: අම්මේ... කොහොමද ඉතින්?"
		elif clock > 7.5 and clock <= 11.0:
			dialogue.text = "ආච්චි: හොඳින් ඉන්නවා දුවේ. ඔයාලව දැක්ක එකම මට සතුටක්."
		elif clock > 11.0 and clock <= 14.5:
			dialogue.text = "කොල්ලා: ආච්චි අම්මේ... මට බඩගිනියි..."
		elif clock > 14.5:
			dialogue.text = "ආච්චි: එන්න පුතේ. කෑමත් ලෑස්ති කරලා තියෙන්නෙ."
		if clock > 18.0:
			begin_play()
	elif state == GameState.PLAY:
		var look: Vector2 = controls.call("consume_look")
		yaw -= look.x * 0.004
		pitch = clamp(pitch-look.y*0.003,-0.55,0.35)
		pivot.rotation = Vector3(pitch,yaw,0)
		update_third_person_camera()

func begin_play() -> void:
	if state == GameState.PLAY:
		return
	state = GameState.PLAY
	clock = 0
	engine.stop()
	cutscene_boy.visible = false
	player.visible = true
	player.position = Vector3(-1.2,1.1,17.4)
	play_cam.current = true
	cine_cam.current = false
	dialogue.visible = false
	dialogue_panel.visible = false
	controls.set_active(true)
	jump_btn.visible = true
	interact_btn.visible = true
	skip_btn.visible = false
	objective.text = "OBJECTIVE: ආච්චිලාගේ වලව්ව ඇතුළට යන්න"

func _physics_process(delta: float) -> void:
	if state != GameState.PLAY:
		return
	var input_vec: Vector2 = controls.get("move_vector")
	var b := Basis(Vector3.UP,yaw)
	var d := b * Vector3(input_vec.x,0,input_vec.y)
	if d.length() > 1:
		d = d.normalized()
	player.velocity.x = d.x * 4.2
	player.velocity.z = d.z * 4.2
	if not player.is_on_floor():
		player.velocity.y -= 9.8 * delta
	if jump_request and player.is_on_floor():
		player.velocity.y = 4.5
	jump_request = false
	player.move_and_slide()
	if d.length() > 0.1:
		body_visual.rotation.y = lerp_angle(body_visual.rotation.y,atan2(d.x,d.z),delta*8)
		animate_walk_pose(body_visual,Time.get_ticks_msec()*0.012,0.75,true)
		step_timer -= delta
		if step_timer <= 0 and player.is_on_floor():
			step_sound.play()
			step_timer = 0.45
	else:
		animate_walk_pose(body_visual,0.0,0.0,true)
		step_timer = 0
	if player.global_position.z > 24.6 and player.global_position.z <= 30.3:
		objective.text = "OBJECTIVE: Main hall එක explore කරන්න"
	elif player.global_position.z > 30.3:
		objective.text = "OBJECTIVE: Rooms, photos සහ kitchen එක explore කරන්න"

func show_timed_dialogue(text_value: String, seconds: float) -> void:
	dialogue_panel.visible = true
	dialogue.visible = true
	dialogue.text = text_value
	await get_tree().create_timer(seconds).timeout
	dialogue.visible = false
	dialogue_panel.visible = false

func on_interact() -> void:
	if player.global_position.distance_to(grandma.global_position) < 3.2:
		await show_timed_dialogue("ආච්චි: පුතා, ඇතුළට ගිහින් වටේ බලන්න. කෑමත් ලෑස්ති කරනවා.",2.8)
		return

	var p: Vector3 = player.global_position
	if p.z > 30.0 and p.x < -1.2:
		await show_timed_dialogue("කොල්ලා: වාව්... මේ kitchen එක පරණ ගමේ kitchen එකක් වගේ!",2.6)
	elif p.z > 30.0 and p.x > 1.2:
		await show_timed_dialogue("කොල්ලා: මේ room එකේ පරණ බඩු ගොඩක් තියෙනවා...",2.6)
	elif p.z > 28.5:
		await show_timed_dialogue("කොල්ලා: මේ photos වල ඉන්නේ අපේ පරණ අය වෙන්න ඇති...",2.6)
	else:
		objective.text = "වලව්ව ඇතුළට ගිහින් rooms explore කරන්න"
