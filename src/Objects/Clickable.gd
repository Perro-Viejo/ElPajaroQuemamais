class_name Clickable
extends Area2D

enum DIR {NONE, LEFT, UP, RIGHT, DOWN}

export (String, "target", "object") var interaction_type 
export var max_distance := 200.0
export var trigger_dialog := ''
export(DIR) var look_to := DIR.NONE

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	connect('input_event', self, '_on_input_event')
	connect('mouse_entered', self, '_on_hover', [true])
	connect('mouse_exited', self, '_on_hover', [false])


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _on_input_event(vp: Node, event: InputEvent, shape: int):
	if event.is_pressed():
		match interaction_type:
			"target":
				PlayerEvent.emit_signal('move_player', self)
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
