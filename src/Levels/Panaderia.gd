extends Node2D

signal commercial_finished

func _ready():
	hide()


func play_commercial():
	show()
	$Camera2D.make_current()
	$AnimationPlayer.play("Comercial")
	$AudioStreamPlayer.play()
	yield($AnimationPlayer, 'animation_finished')
