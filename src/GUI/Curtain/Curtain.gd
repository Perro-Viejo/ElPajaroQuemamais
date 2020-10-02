extends Control

func _ready() -> void:
	WorldEvent.connect('episode_started', self, '_hide_curtain')
	WorldEvent.connect('episode_ended', self, '_show_curtain')
	
	$CanvasLayer/ColorRect.hide()

func _hide_curtain() -> void:
	$CanvasLayer/ColorRect.show()
	$AnimationPlayer.play('show_scene')
	yield($AnimationPlayer, 'animation_finished')
	$CanvasLayer/ColorRect.hide()
	GuiEvent.emit_signal('curtain_hidden')


func _show_curtain() -> void:
	$CanvasLayer/ColorRect.show()
	$AnimationPlayer.play_backwards('show_scene')
	yield($AnimationPlayer, 'animation_finished')
	GuiEvent.emit_signal('curtain_shown')
