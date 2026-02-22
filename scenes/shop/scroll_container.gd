extends ScrollContainer

var dragging = false
var drag_start_pos = Vector2.ZERO
var scroll_start = Vector2.ZERO

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start_pos = event.position
				scroll_start = Vector2(scroll_horizontal, scroll_vertical)
			else:
				dragging = false

	elif event is InputEventMouseMotion and dragging:
		var drag_delta = drag_start_pos - event.position
		scroll_horizontal = int(scroll_start.x + drag_delta.x)
		scroll_vertical = int(scroll_start.y + drag_delta.y)
