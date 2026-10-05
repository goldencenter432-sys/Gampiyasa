extends Node

# v0.2.6 procedural soundscape.
# Real ambient/SFX are generated at runtime; speaker tracks are timing scratch cues,
# ready to be replaced with recorded/TTS Sinhala dialogue assets.

var wind: AudioStreamPlayer
var birds: AudioStreamPlayer
var insects: AudioStreamPlayer
var one_shot: AudioStreamPlayer
var voice: AudioStreamPlayer
var cue_flags: Dictionary = {}
var last_state: int = -1

func _ready() -> void:
	name = "Soundscape_v0_2_6"
	wind = AudioStreamPlayer.new()
	birds = AudioStreamPlayer.new()
	insects = AudioStreamPlayer.new()
	one_shot = AudioStreamPlayer.new()
	voice = AudioStreamPlayer.new()
	add_child(wind)
	add_child(birds)
	add_child(insects)
	add_child(one_shot)
	add_child(voice)

	wind.stream = _make_wind(4.0)
	birds.stream = _make_birds(5.0)
	insects.stream = _make_insects(4.0)
	wind.volume_db = -27.0
	birds.volume_db = -21.0
	insects.volume_db = -31.0
	one_shot.volume_db = -10.0
	voice.volume_db = -18.0
	wind.play()
	birds.play()
	insects.play()

func _looped(wav: AudioStreamWAV) -> AudioStreamWAV:
	wav.loop_mode = AudioStreamWAV.LOOP_FORWARD
	return wav

func _wav_from_samples(samples: PackedFloat32Array, rate: int = 22050) -> AudioStreamWAV:
	var data: PackedByteArray = PackedByteArray()
	data.resize(samples.size()*2)
	for i: int in range(samples.size()):
		var sample: int = int(clampf(samples[i],-1.0,1.0)*15000.0)
		data.encode_s16(i*2,sample)
	var wav: AudioStreamWAV = AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = rate
	wav.stereo = false
	wav.data = data
	return wav

func _make_wind(seconds: float) -> AudioStreamWAV:
	var rate: int = 22050
	var count: int = int(seconds*float(rate))
	var s: PackedFloat32Array = PackedFloat32Array()
	s.resize(count)
	var smooth: float = 0.0
	for i: int in range(count):
		var t: float = float(i)/float(rate)
		smooth = lerpf(smooth,randf_range(-1.0,1.0),0.018)
		var gust: float = 0.34+0.18*sin(TAU*0.16*t)+0.10*sin(TAU*0.31*t+1.2)
		s[i] = smooth*gust*0.34
	return _looped(_wav_from_samples(s,rate))

func _make_birds(seconds: float) -> AudioStreamWAV:
	var rate: int = 22050
	var count: int = int(seconds*float(rate))
	var s: PackedFloat32Array = PackedFloat32Array()
	s.resize(count)
	for i: int in range(count):
		var t: float = float(i)/float(rate)
		var v: float = 0.0
		var cycle: float = fmod(t,1.35)
		if cycle < 0.20:
			var env: float = sin(PI*cycle/0.20)
			var f: float = 1450.0+520.0*(cycle/0.20)
			v += sin(TAU*f*t)*env*0.30
		var cycle2: float = fmod(t+0.62,2.1)
		if cycle2 < 0.16:
			var env2: float = sin(PI*cycle2/0.16)
			v += sin(TAU*(1980.0+260.0*sin(TAU*7.0*t))*t)*env2*0.18
		s[i] = v
	return _looped(_wav_from_samples(s,rate))

func _make_insects(seconds: float) -> AudioStreamWAV:
	var rate: int = 22050
	var count: int = int(seconds*float(rate))
	var s: PackedFloat32Array = PackedFloat32Array()
	s.resize(count)
	for i: int in range(count):
		var t: float = float(i)/float(rate)
		var pulse: float = maxf(0.0,sin(TAU*6.3*t))
		s[i] = sin(TAU*3550.0*t)*pulse*0.045
	return _looped(_wav_from_samples(s,rate))

func _make_door_creak() -> AudioStreamWAV:
	var rate: int = 22050
	var seconds: float = 1.15
	var count: int = int(seconds*float(rate))
	var s: PackedFloat32Array = PackedFloat32Array()
	s.resize(count)
	for i: int in range(count):
		var t: float = float(i)/float(rate)
		var env: float = sin(PI*clampf(t/seconds,0.0,1.0))
		var f: float = 150.0+45.0*sin(TAU*1.7*t)+18.0*sin(TAU*8.0*t)
		s[i] = (sin(TAU*f*t)*0.35+randf_range(-1.0,1.0)*0.06)*env
	return _wav_from_samples(s,rate)

func _make_car_door() -> AudioStreamWAV:
	var rate: int = 22050
	var seconds: float = 0.34
	var count: int = int(seconds*float(rate))
	var s: PackedFloat32Array = PackedFloat32Array()
	s.resize(count)
	for i: int in range(count):
		var t: float = float(i)/float(rate)
		var env: float = exp(-18.0*t)
		s[i] = (sin(TAU*92.0*t)*0.60+randf_range(-1.0,1.0)*0.35)*env
	return _wav_from_samples(s,rate)

func _make_gravel_stop() -> AudioStreamWAV:
	var rate: int = 22050
	var seconds: float = 0.70
	var count: int = int(seconds*float(rate))
	var s: PackedFloat32Array = PackedFloat32Array()
	s.resize(count)
	var smooth: float = 0.0
	for i: int in range(count):
		var t: float = float(i)/float(rate)
		smooth = lerpf(smooth,randf_range(-1.0,1.0),0.32)
		var env: float = exp(-3.5*t)
		s[i] = smooth*env*0.44
	return _wav_from_samples(s,rate)

func _make_voice_scratch(speaker: String) -> AudioStreamWAV:
	# Non-verbal formant-style scratch cue, used only to test dialogue timing.
	var rate: int = 22050
	var seconds: float = 1.35
	var count: int = int(seconds*float(rate))
	var base: float = 175.0
	if speaker == "boy":
		base = 245.0
	elif speaker == "mother":
		base = 205.0
	elif speaker == "grandma":
		base = 155.0
	elif speaker == "father":
		base = 170.0
	var s: PackedFloat32Array = PackedFloat32Array()
	s.resize(count)
	for i: int in range(count):
		var t: float = float(i)/float(rate)
		var syllable: float = maxf(0.0,sin(TAU*2.7*t))
		var env: float = sin(PI*clampf(t/seconds,0.0,1.0))*syllable
		var vibrato: float = base+4.5*sin(TAU*5.1*t)
		var v: float = sin(TAU*vibrato*t)*0.22
		v += sin(TAU*(vibrato*2.15)*t)*0.11
		v += sin(TAU*(vibrato*3.05)*t)*0.05
		s[i] = v*env
	return _wav_from_samples(s,rate)

func play_event(event_name: String) -> void:
	if event_name == "door_creak":
		one_shot.stream = _make_door_creak()
	elif event_name == "car_door":
		one_shot.stream = _make_car_door()
	elif event_name == "gravel_stop":
		one_shot.stream = _make_gravel_stop()
	else:
		return
	one_shot.play()

func play_voice_scratch(speaker: String) -> void:
	voice.stream = _make_voice_scratch(speaker)
	voice.play()

func update_cues(game_state: int, scene_clock: float) -> void:
	if game_state != last_state:
		last_state = game_state
		cue_flags.clear()

	# ARRIVAL = 1, DIALOGUE = 2 in main.gd enum.
	if game_state == 1:
		if scene_clock > 0.05 and not cue_flags.has("stop"):
			cue_flags["stop"] = true
			play_event("gravel_stop")
		if scene_clock > 2.55 and not cue_flags.has("car_door_1"):
			cue_flags["car_door_1"] = true
			play_event("car_door")
		if scene_clock > 4.05 and not cue_flags.has("car_door_2"):
			cue_flags["car_door_2"] = true
			play_event("car_door")
		if scene_clock > 8.05 and not cue_flags.has("house_door"):
			cue_flags["house_door"] = true
			play_event("door_creak")
	elif game_state == 2:
		if scene_clock > 0.08 and not cue_flags.has("v0"):
			cue_flags["v0"] = true
			play_voice_scratch("grandma")
		if scene_clock > 4.05 and not cue_flags.has("v1"):
			cue_flags["v1"] = true
			play_voice_scratch("mother")
		if scene_clock > 7.55 and not cue_flags.has("v2"):
			cue_flags["v2"] = true
			play_voice_scratch("grandma")
		if scene_clock > 11.05 and not cue_flags.has("v3"):
			cue_flags["v3"] = true
			play_voice_scratch("boy")
		if scene_clock > 14.55 and not cue_flags.has("v4"):
			cue_flags["v4"] = true
			play_voice_scratch("grandma")
