extends "res://src/StateMachine/State.gd"

func play_animation() -> bool:
	$AnimatedSprite.play('default')
	return true

func _on_frame_changed():
	if sprite.frame in fs_sfx_frames:
		AudioEvent.emit_signal('play_requested', 'FS', owner.name)
