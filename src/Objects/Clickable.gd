extends Area2D

export (String, "target", "object") var interaction_type 

export (float) var max_distance = 200

func _ready():
	connect('input_event', self, '_on_input_event')
	connect('mouse_entered', self, '_on_hover', [true])
	connect('mouse_exited', self, '_on_hover', [false])

func _on_input_event(vp, event, shape):
	if event.is_pressed():
		match interaction_type:
			"target":
				PlayerEvent.emit_signal('move_player', position)
			"object":
				PlayerEvent.emit_signal('check_object', position, max_distance)

func _on_hover(is_in: bool) -> void:
	if is_in:
		match interaction_type:
			"target":
				Input.set_default_cursor_shape(Input.CURSOR_MOVE)
			"object":
				Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
