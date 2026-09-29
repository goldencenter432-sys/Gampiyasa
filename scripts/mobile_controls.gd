extends Control

var move_vector := Vector2.ZERO
var look_delta := Vector2.ZERO
var move_id := -1
var look_id := -1
var origin := Vector2.ZERO
var current := Vector2.ZERO
var radius := 86.0
var active := false

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_process_input(true)
	queue_redraw()

func set_active(v: bool) -> void:
	active = v
	visible = v
	if not v:
		move_vector = Vector2.ZERO
		move_id = -1
		look_id = -1
	queue_redraw()

func consume_look() -> Vector2:
	var d := look_delta
	look_delta = Vector2.ZERO
	return d

func _input(event: InputEvent) -> void:
	if not active:
		return
	if event is InputEventScreenTouch:
		var t := event as InputEventScreenTouch
		if t.pressed:
			if t.position.x < size.x * 0.47 and t.position.y > size.y * 0.32 and move_id == -1:
				move_id = t.index
				origin = t.position
				current = t.position
			elif look_id == -1:
				look_id = t.index
		else:
			if t.index == move_id:
				move_id = -1
				move_vector = Vector2.ZERO
			if t.index == look_id:
				look_id = -1
			queue_redraw()
	elif event is InputEventScreenDrag:
		var d := event as InputEventScreenDrag
		if d.index == move_id:
			var delta := d.position - origin
			if delta.length() > radius:
				delta = delta.normalized() * radius
			current = origin + delta
			move_vector = delta / radius
			queue_redraw()
		elif d.index == look_id:
			look_delta += d.relative

func _draw() -> void:
	if not active:
		return
	var base := origin if move_id != -1 else Vector2(120, size.y - 120)
	var knob := current if move_id != -1 else base
	draw_circle(base, radius, Color(1,1,1,0.12))
	draw_arc(base, radius, 0, TAU, 40, Color(1,1,1,0.42), 3)
	draw_circle(knob, 34, Color(1,1,1,0.35))
