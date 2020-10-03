extends Control

var current_tutorial
var first_move = true

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready():
	# Conectarse a eventos propios y de los hijos
	connect('gui_input', self, '_on_input_event')
	
	# Conectarse a eventos del universo
	HudEvent.connect('tutorial_requested', self, '_show_tutorial')
	DialogEvent.connect('dialog_finished', self, '_check_tutorial_after_dialog')


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos privados ▒▒▒▒
func _on_input_event(event: InputEvent):
	if event.is_pressed():
		WorldEvent.emit_signal('tutorial_shown', current_tutorial)
		Data.set_data(Data.CURRENT_TUTORIAL, current_tutorial + 1)
		hide()
		DialogEvent.emit_signal('subs_done')


func _show_tutorial(tutorial := -1):
	if tutorial < 0: return
	current_tutorial = tutorial
	DialogEvent.emit_signal('subs_requested', 'TUTORIAL_%d' % tutorial)
	show()
	match tutorial:
		0:
			$Panel/Tutorials/Movement.show()
			$MovementIcons.show()
		1:
			$Panel/Tutorials/Interact.show()
			$Interact.show()
			$Panel/Tutorials/Movement.hide()
			$MovementIcons.hide()

func _check_tutorial_after_dialog(dialog_name) -> void:
	match dialog_name:
		'Ep1Sc1':
			_show_tutorial(0)
		'Ep1Sc2':
			_show_tutorial(1)
