class_name NPC
extends "res://src/Characters/Actor.gd"

var node_to_interact: Pickable = null setget _set_node_to_interact
var grabbing: bool = false
var on_ground: bool = false
var foot = 'L'
var is_paused := false
var is_out: bool = false
var is_moving = false
var dir = Vector2(0, 0)

#onready var foot_area: Area2D = $FootArea

func _ready() -> void:
	# Conectarse a eventos del universo
	if not DialogEvent.is_connected('line_triggered', self, '_should_speak'):
		DialogEvent.connect('line_triggered', self, '_should_speak')
	PlayerEvent.connect('control_toggled', self, '_toggle_control')
	

func change_zoom(out: bool = true) -> void:
	is_out = out
	
	if out:
		AudioEvent.emit_signal('play_requested', 'UI', 'ZoomOut')
	else:
		AudioEvent.emit_signal('play_requested', 'UI', 'ZoomIn')

	yield($Tween, 'tween_completed')

func toggle_on_ground(body: Node2D, on: = false) -> void:
	if not body.is_in_group('Floor'): return

#	on_ground = on
#
#	if on_ground:
#
#		var tile_map: TileMap = body as TileMap
#		var tile_pos: Vector2 = (foot_area.global_position / 8).floor()
#		# Gono-style
#
#		tile_pos.x += dir.x
#
#		if dir.y > 0:
#			tile_pos.y += 1


func _toggle_control() -> void:
	$StateMachine.transition_to_state($StateMachine.STATES.IDLE)
	is_paused = !is_paused

func _set_node_to_interact(new_node: Pickable) -> void:
	if node_to_interact:
		node_to_interact.hide_interaction()
	if new_node and new_node.is_in_group('Pickable'):
		new_node.show_interaction()

	node_to_interact = new_node


func _set_fishing(value: bool) -> void:
	$StateMachine.state.play_animation()
