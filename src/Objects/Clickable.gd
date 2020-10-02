tool
class_name Clickable
extends Area2D

signal interacted

enum DIR {NONE, LEFT, UP, RIGHT, DOWN}

export (String, 'target', 'object') var interaction_type = 'target'
export var max_distance := 500.0
export var trigger_dialog := ''
export(DIR) var look_to := DIR.NONE
export var enabled := true
export var disable_after_interactions := 0

var _interactions := 0

var room: Node2D

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	connect('input_event', self, '_on_input_event')
	connect('mouse_entered', self, '_on_hover', [true])
	connect('mouse_exited', self, '_on_hover', [false])
	
	match interaction_type:
		'target':
			self.modulate = Color.blue
		'object':
			self.modulate = Color.yellow


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func is_near_to(pos: Vector2) -> bool:
	return self.global_position.distance_to(pos) <= max_distance


func interact() -> void:
	_interactions += 1
	
	if disable_after_interactions > 0 and _interactions == disable_after_interactions:
		enabled = false

	emit_signal('interacted')


func get_room_relative_position() -> Vector2:
	return self.position + room.position


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _on_input_event(vp: Node, event: InputEvent, shape: int):
	if not enabled: return
	if event.is_pressed():
		match interaction_type:
			'target':
				PlayerEvent.emit_signal('move_player', self)
			'object':
				PlayerEvent.emit_signal('check_object', self)

func _on_hover(is_in: bool) -> void:
	if not enabled: return
	if is_in:
		match interaction_type:
			'target':
				Input.set_default_cursor_shape(Input.CURSOR_MOVE)
			'object':
				Input.set_default_cursor_shape(Input.CURSOR_POINTING_HAND)
	else:
		Input.set_default_cursor_shape(Input.CURSOR_ARROW)
