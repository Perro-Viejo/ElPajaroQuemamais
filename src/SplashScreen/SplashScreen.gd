extends CanvasLayer

export (String, FILE, '*.tscn') var main_menu: String
export var ignore_fade := false

func _ready():
	$SplashScreen/AnimationPlayer.connect(
		'animation_finished', self, '_on_animation_finished'
	)

	if not Settings.HTML5:
		$SplashScreen/AnimationPlayer.play('splash')
	else:
		# Si estamos en HTML5 hay que esperar a que le den clic al de empezar
		GuiEvent.connect(
			'html5_clicked', $SplashScreen/AnimationPlayer, 'play', ['splash']
		)

func _on_animation_finished(anim):
	GuiEvent.emit_signal('ChangeScene', main_menu)

func _play_sfx(key):
	SoundManager.play_se(key)
