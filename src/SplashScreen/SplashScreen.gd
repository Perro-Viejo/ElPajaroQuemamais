extends CanvasLayer

export (String, FILE, '*.tscn') var main_menu: String
export var ignore_fade := false

func _ready():
	$SplashScreen/AnimationPlayer.play('splash')
	$SplashScreen/AnimationPlayer.connect('animation_finished', self, '_on_animation_finished')

func _on_animation_finished(anim):
	GuiEvent.emit_signal('ChangeScene', main_menu)
