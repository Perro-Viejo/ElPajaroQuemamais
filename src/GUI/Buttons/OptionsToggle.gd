extends CheckButton
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
export(Color) var highligth
export(Color) var normal
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready():
	self_modulate = normal
	connect('focus_entered', self, 'set_self_modulate', [highligth])
	connect('focus_exited', self, 'set_self_modulate', [normal])
	connect('button_down',self, 'play_toggle_sfx')

func play_toggle_sfx():
	SoundManager.play_se('ui_select')
