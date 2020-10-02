class_name Room
extends Node2D

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	_assign_self_to([$Targets, $Objects])


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func get_point_position(point_name: String) -> Vector2:
	return self.position + _get_child_position('Points', point_name)


func get_target_position(point_name: String) -> Vector2:
	return self.position + _get_child_position('Targets', point_name)


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _assign_self_to(containers := []) -> void:
	for cnt in containers:
		for child in cnt.get_children():
			child.room = self


func _get_child_position(container: String, child_name: String) -> Vector2:
	var pos := Vector2.ZERO
	if get_node(container).has_node(child_name):
		pos = self.get_node('%s/%s' % [container, child_name]).position
	return pos
