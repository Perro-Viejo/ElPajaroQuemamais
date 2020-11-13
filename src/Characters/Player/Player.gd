class_name Player
extends 'res://src/Characters/Actor.gd'

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables públicas ▒▒▒▒
var node_to_interact: Pickable = null setget _set_node_to_interact
var grabbing: bool = false
var on_ground: bool = false
var foot = 'L'
var is_paused := false
var is_out: bool = false
var is_moving = false

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	self.connect('movement_started', self, '_movement_changed')
	self.connect('movement_finished', self, '_movement_changed')
	
	PlayerEvent.connect('check_object', self, '_on_object_check')


func _process(delta):
	if path.size() > 0:
		rotation = path[0].angle_to_point(position)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _set_node_to_interact(new_node: Pickable) -> void:
	if node_to_interact:
		node_to_interact.hide_interaction()
	if new_node and new_node.is_in_group('Pickable'):
		new_node.show_interaction()

	node_to_interact = new_node


func _set_fishing(value: bool) -> void:
	$StateMachine.state.play_animation()


func _on_object_check(clickable: Clickable):
	if clickable.is_near_to(self.global_position):
		clickable.interact()
		var emotions = ['excited','happy','normal','surprised']
		SoundManager.play_se('dx_player_' + emotions[randi() % emotions.size()])
	else:
		speak('ta lejambres')


func _movement_changed(actor: Actor) -> void:
	if .is_moving():
		$StateMachine.transition_to_key('Move')
	else:
		$StateMachine.transition_to_key('Idle')
		PlayerEvent.emit_signal('movement_finished')
