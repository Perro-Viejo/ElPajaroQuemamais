class_name Player
extends "res://src/Characters/Actor.gd"

var node_to_interact: Pickable = null setget _set_node_to_interact
var grabbing: bool = false
var on_ground: bool = false
var foot = 'L'
var is_paused := false
var is_out: bool = false
var is_moving = false

func _ready():
	PlayerEvent.connect('check_object', self, '_on_object_check')

func _set_node_to_interact(new_node: Pickable) -> void:
	if node_to_interact:
		node_to_interact.hide_interaction()
	if new_node and new_node.is_in_group('Pickable'):
		new_node.show_interaction()

	node_to_interact = new_node

func _set_fishing(value: bool) -> void:
	$StateMachine.state.play_animation()

func _process(delta):
	if path.size() > 0:
		rotation = path[0].angle_to_point(position)

func _on_object_check(obj_pos, max_dist):
	print(position.distance_to(obj_pos))
	if position.distance_to(obj_pos) < max_dist:
		speak("Interactuamelo")
	else:
		speak("ta lejambres")

