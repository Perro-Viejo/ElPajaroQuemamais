extends "res://src/StateMachine/State.gd"

func play_animation() -> bool:
	$AnimatedSprite.play('default')
	return true

func _on_frame_changed():
	# TODO:	Hacer algo menos chirri después de entender cómo funciona el mundo
	#		Y la sociedad de consumo capitalista.
	if _state_machine.state.name == 'Move' and  sprite.frame in fs_sfx_frames:
		AudioEvent.emit_signal('play_requested', 'FS', owner.name)
