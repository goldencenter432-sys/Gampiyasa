extends Node3D

const MobileControls = preload("res://scripts/mobile_controls.gd")
enum GameState { DRIVE, ARRIVAL, DIALOGUE, PLAY }

var state := GameState.DRIVE
var clock := 0.0
var car: Node3D
var family: Node3D
var grandma: Node3D
var player: CharacterBody3D
var body_visual: Node3D
var pivot: Node3D
var play_cam: Camera3D
var cine_cam: Camera3D
var controls: Control
var dialogue: Label
var objective: Label
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
var drive_a := Vector3(0,0.65,-35)
var drive_b := Vector3(0,0.65,14)

func _ready() -> void:
	build_world()
	build_village()
	build_house()
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
	sm.sky_top_color = Color("4b86c9")
	sm.sky_horizon_color = Color("c9e4f1")
	sm.ground_bottom_color = Color("47643e")
	sky.sky_material = sm
	e.sky = sky
	e.ambient_light_source = Environment.AMBIENT_SOURCE_SKY
	e.ambient_light_energy = 0.8
	e.tonemap_mode = Environment.TONE_MAPPER_FILMIC
	e.fog_enabled = true
	e.fog_density = 0.003
	we.environment = e
	add_child(we)
	var sun := DirectionalLight3D.new()
	sun.rotation_degrees = Vector3(-48,-25,0)
	sun.light_energy = 1.25
	sun.shadow_enabled = true
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
	return n

func build_people_and_car() -> void:
	car = Node3D.new()
	car.position = drive_a
	add_child(car)
	box(car,Vector3(0,0.65,0),Vector3(2.4,0.8,4.2),Color("285d73"))
	box(car,Vector3(0,1.25,0.1),Vector3(2.05,0.75,2.3),Color("557f8b"))
	for x in [-1.15,1.15]:
		for z in [-1.35,1.35]:
			var w := cylinder(car,Vector3(x,0.35,z),0.42,0.3,Color("171717"))
			w.rotation_degrees.z = 90
	family = Node3D.new()
	family.visible = false
	add_child(family)
	person(family,Vector3(-2.2,0,16),Color("526d8b"))
	person(family,Vector3(2.1,0,15.7),Color("9b617c"),0.95)
	person(family,Vector3(3.4,0,16.6),Color("d19d44"),0.78)
	grandma = person(self,Vector3(-1.3,0,22.9),Color("d6cdb1"),0.9)
	box(grandma,Vector3(0,1.15,0.03),Vector3(0.9,1.2,0.16),Color("8f6481"))

func build_player() -> void:
	player = CharacterBody3D.new()
	player.position = Vector3(0,1.1,18)
	add_child(player)
	var cs := CollisionShape3D.new()
	var cap := CapsuleShape3D.new()
	cap.radius = 0.38
	cap.height = 1.55
	cs.shape = cap
	player.add_child(cs)
	body_visual = person(player,Vector3(0,-0.95,0),Color("4b76a5"),0.72)
	pivot = Node3D.new()
	player.add_child(pivot)
	pivot.position = Vector3(0,1.2,0)
	play_cam = Camera3D.new()
	play_cam.position = Vector3(0,1.2,-4.8)
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
	objective = Label.new()
	objective.position = Vector2(28,26)
	objective.add_theme_font_size_override("font_size",22)
	objective.text = "ගමට යන ගමන්..."
	layer.add_child(objective)
	dialogue = Label.new()
	dialogue.position = Vector2(100,560)
	dialogue.size = Vector2(1080,100)
	dialogue.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	dialogue.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	dialogue.add_theme_font_size_override("font_size",28)
	dialogue.add_theme_color_override("font_color",Color.WHITE)
	dialogue.visible = false
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
	cine_cam.current = true
	play_cam.current = false
	engine.play()

func _process(delta: float) -> void:
	clock += delta
	if state == GameState.DRIVE:
		var t := clamp(clock/9.0,0.0,1.0)
		car.position = drive_a.lerp(drive_b,smoothstep(0,1,t))
		cine_cam.global_position = car.global_position + Vector3(8,4.5,-9)
		cine_cam.look_at(car.global_position+Vector3(0,0.8,2),Vector3.UP)
		if t >= 1:
			state = GameState.ARRIVAL
			clock = 0
			family.visible = true
			engine.stop()
			objective.text = "ආච්චිලාගේ ගෙදරට ආවා"
	elif state == GameState.ARRIVAL:
		cine_cam.global_position = Vector3(6,3.5,19)
		cine_cam.look_at(Vector3(0,1.5,23),Vector3.UP)
		if clock > 2.8:
			state = GameState.DIALOGUE
			clock = 0
			dialogue.visible = true
			dialogue.text = "ආච්චි: ආ මේ ළමයිනේ! එන්න ඇතුළට. ගොඩ කාලෙකින් ඔයාලව දැක්කෙ."
	elif state == GameState.DIALOGUE:
		if clock > 4.5:
			dialogue.text = "කොල්ලා: ආච්චි අම්මේ... බඩගිනියි!"
		if clock > 8.0:
			begin_play()
	elif state == GameState.PLAY:
		var look: Vector2 = controls.call("consume_look")
		yaw -= look.x * 0.004
		pitch = clamp(pitch-look.y*0.003,-0.55,0.35)
		pivot.rotation = Vector3(pitch,yaw,0)

func begin_play() -> void:
	if state == GameState.PLAY:
		return
	state = GameState.PLAY
	clock = 0
	engine.stop()
	player.visible = true
	player.position = Vector3(0,1.1,18)
	play_cam.current = true
	cine_cam.current = false
	dialogue.visible = false
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
		step_timer -= delta
		if step_timer <= 0 and player.is_on_floor():
			step_sound.play()
			step_timer = 0.45
	else:
		step_timer = 0
	if player.global_position.z > 24.6:
		objective.text = "OBJECTIVE COMPLETE ✓  වලව්ව ඇතුළත explore කරන්න"

func on_interact() -> void:
	if player.global_position.distance_to(grandma.global_position) < 3.2:
		dialogue.visible = true
		dialogue.text = "ආච්චි: පුතා, ඇතුළට ගිහින් කෑම කන්න."
		await get_tree().create_timer(2.5).timeout
		dialogue.visible = false
	else:
		objective.text = "Interact කරන්න ආච්චි ළඟට යන්න"
