extends Area2D

export (String, "target", "object") var interaction_type 

export (float) var max_distance = 200

func _ready():
	connect('input_event', self, '_on_input_event')

func _on_input_event(vp, event, shape):
	if event.is_pressed():
		match interaction_type:
			"target":
				PlayerEvent.emit_signal('move_player', position)
			"object":
				PlayerEvent.emit_signal('check_object', position, max_distance)
