extends Label

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables privadas ▒▒▒▒
var _sub_shown = false
var _played = false
var _visible_position_y := 900.0
onready var _out_position_y := OS.window_size.y

func _ready() -> void:
	$Tween.connect('tween_step', self, '_play_subs_sfx')
	DialogEvent.connect('subs_requested', self, '_one_shot_subs')
	DialogEvent.connect('subs_done', self, 'toggle_subs', [false])


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func toggle_subs(show := true) -> void:
	if not show and self.rect_position.y == _out_position_y: return
	
	_sub_shown = show
	_played = false
	$Tween.interpolate_property(
		self, 'rect_position:y',
		_out_position_y if show else _visible_position_y,
		_visible_position_y if show else _out_position_y,
		0.3 if show else 0.1,
		Tween.TRANS_BOUNCE if show else Tween.TRANS_SINE,
		Tween.EASE_OUT if show else Tween.EASE_IN
	)
	$Tween.start()
	if not show:
		yield($Tween, 'tween_completed')
		set_text('[ gibberish in spanish ]')


func put_out() -> void:
	self.rect_position.y = _out_position_y


func _play_subs_sfx(obj: Object, key: NodePath, elapsed: float, val: Object):
	if _sub_shown and not _played and (obj as Control).rect_position.y < 905:
		_played = true
		AudioEvent.emit_signal('play_requested', 'UI', 'sub')


func _one_shot_subs(tr_code: String) -> void:
	TranslationServer.set_locale('en')
	text = tr(tr_code)
	TranslationServer.set_locale('es')
	toggle_subs()
