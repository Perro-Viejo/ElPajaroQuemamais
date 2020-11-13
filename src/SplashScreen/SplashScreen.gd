extends Control

export var main_menu: String

func _ready():
	$AnimationPlayer.play('splash')
	$AnimationPlayer.connect('animation_finished', self, '_on_animation_finished')

func _on_animation_finished(anim):
	GuiEvent.emit_signal('ChangeScene', main_menu)
