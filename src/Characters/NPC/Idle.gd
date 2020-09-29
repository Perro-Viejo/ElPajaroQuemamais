extends "res://src/StateMachine/State.gd"

func play_animation() -> bool:
	$AnimatedSprite.play('default')
	return true
