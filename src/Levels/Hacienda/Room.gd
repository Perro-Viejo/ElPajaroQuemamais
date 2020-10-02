class_name Room
extends Node2D

func _ready():
	_assign_self_to([$Targets, $Objects])
	
#	for obj in $Objects.get_children():
#		obj.connect


func _assign_self_to(containers := []) -> void:
	for cnt in containers:
		for child in cnt.get_children():
			child.room = self
