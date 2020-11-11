extends TextureButton

onready var _dflt_pos := rect_position
onready var _out_pos_x := OS.window_size.x + 16

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready() -> void:
	rect_position.x = _out_pos_x
	connect('mouse_entered', self, '_on_hover')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func toggle(show := true) -> void:
	show()
	$Tween.interpolate_property(
		self, 'rect_position:x',
		_out_pos_x if show else _dflt_pos.x,
		_dflt_pos.x if show else _out_pos_x,
		0.3 if show else 0.1,
		Tween.TRANS_BOUNCE if show else Tween.TRANS_SINE,
		Tween.EASE_OUT if show else Tween.EASE_IN
	)
	$Tween.start()
	SoundManager.play_se('ui_player_show')
	disabled = !show


func is_in_view() -> bool:
	return rect_position.x == _dflt_pos.x


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _on_hover():
	SoundManager.play_se('ui_player_hover')
