class_name NotebookDrawingCanvas
extends Control

signal strokes_changed(strokes: Array)

const PAGE_COLOR := Color("#f3e8cf")
const RULE_COLOR := Color(0.48, 0.38, 0.28, 0.18)
const MARGIN_COLOR := Color(0.55, 0.15, 0.15, 0.25)
const BORDER_COLOR := Color("#6b4d32")
const MIN_POINT_DISTANCE := 1.5

@export var brush_color := Color("#3b2416")
@export_range(1.0, 16.0, 0.5) var brush_width := 3.0

var _strokes: Array[Dictionary] = []
var _is_drawing := false
var _active_stroke_index := -1


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_STOP
	resized.connect(queue_redraw)
	queue_redraw()


func _gui_input(event: InputEvent) -> void:
	if (
		event is InputEventMouseButton
		and event.button_index == MOUSE_BUTTON_LEFT
	):
		if event.pressed:
			_start_stroke(event.position)
		else:
			_finish_stroke()

		accept_event()
		return

	if (
		event is InputEventMouseMotion
		and _is_drawing
		and event.button_mask & MOUSE_BUTTON_MASK_LEFT
	):
		_add_point(event.position)
		accept_event()


func set_brush_color(color: Color) -> void:
	brush_color = color


func set_brush_width(width: float) -> void:
	brush_width = clampf(width, 1.0, 16.0)


func set_strokes(strokes: Array) -> void:
	_strokes.clear()
	for stroke in strokes:
		if stroke is Dictionary:
			_strokes.append(stroke.duplicate(true))

	_is_drawing = false
	_active_stroke_index = -1
	queue_redraw()


func get_strokes() -> Array:
	return _strokes.duplicate(true)


func undo_last_stroke() -> void:
	if _strokes.is_empty():
		return

	_strokes.pop_back()
	strokes_changed.emit(get_strokes())
	queue_redraw()


func clear_drawing() -> void:
	if _strokes.is_empty():
		return

	_strokes.clear()
	strokes_changed.emit(get_strokes())
	queue_redraw()


func _start_stroke(position: Vector2) -> void:
	var points := PackedVector2Array()
	points.append(_clamp_to_canvas(position))

	_strokes.append({
		"points": points,
		"color": brush_color,
		"width": brush_width,
	})
	_active_stroke_index = _strokes.size() - 1
	_is_drawing = true
	queue_redraw()


func _add_point(position: Vector2) -> void:
	if (
		not _is_drawing
		or _active_stroke_index < 0
		or _active_stroke_index >= _strokes.size()
	):
		return

	var points: PackedVector2Array = (
		_strokes[_active_stroke_index]["points"]
	)
	var next_point := _clamp_to_canvas(position)

	if (
		not points.is_empty()
		and points[-1].distance_to(next_point)
		< MIN_POINT_DISTANCE
	):
		return

	points.append(next_point)
	_strokes[_active_stroke_index]["points"] = points
	queue_redraw()


func _finish_stroke() -> void:
	if not _is_drawing:
		return

	_is_drawing = false
	_active_stroke_index = -1
	strokes_changed.emit(get_strokes())
	queue_redraw()


func _clamp_to_canvas(point: Vector2) -> Vector2:
	return Vector2(
		clampf(point.x, 0.0, size.x),
		clampf(point.y, 0.0, size.y)
	)


func _draw() -> void:
	draw_rect(
		Rect2(Vector2.ZERO, size),
		PAGE_COLOR,
		true
	)

	var line_y := 24.0
	while line_y < size.y:
		draw_line(
			Vector2(0.0, line_y),
			Vector2(size.x, line_y),
			RULE_COLOR,
			1.0
		)
		line_y += 24.0

	draw_line(
		Vector2(30.0, 0.0),
		Vector2(30.0, size.y),
		MARGIN_COLOR,
		1.0
	)

	for stroke in _strokes:
		var points: PackedVector2Array = stroke.get(
			"points",
			PackedVector2Array()
		)
		var color: Color = stroke.get(
			"color",
			brush_color
		)
		var width: float = stroke.get(
			"width",
			brush_width
		)

		if points.size() == 1:
			draw_circle(
				points[0],
				maxf(width * 0.5, 1.0),
				color
			)
		elif points.size() > 1:
			draw_polyline(
				points,
				color,
				width,
				true
			)

	draw_rect(
		Rect2(Vector2.ZERO, size),
		BORDER_COLOR,
		false,
		2.0
	)
