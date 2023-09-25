extends Camera2D

var zoomDelta = 0.5
var zoomMin = Vector2(0.5, 0.5)
var zoomMax = Vector2(4, 4)
var dragging = false
var previousMousePos
var previousCamPos

func _input(event):
	if event is InputEventMouseButton:
		if event.is_pressed():
			# zoom in
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var newZoom = zoom + Vector2(zoomDelta, zoomDelta)
				zoom = newZoom.clamp(zoomMin, zoomMax)
			# zoom out
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var newZoom = zoom - Vector2(zoomDelta, zoomDelta)				
				zoom = newZoom.clamp(zoomMin, zoomMax)
				
			if event.button_index == MOUSE_BUTTON_LEFT:
				dragging = true
				previousMousePos = event.position
				previousCamPos = position
		else:
			dragging = false
	elif event is InputEventMouseMotion and dragging:
		position = previousMousePos - event.position + previousCamPos
