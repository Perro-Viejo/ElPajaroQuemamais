class_name Hud
extends CanvasLayer

var world_entered: bool = false

onready var _dialog: Dialog = find_node('Dialog')

func _ready() -> void:
	_dialog.hide()

	# Conectarse a los eventos del señor
	WorldEvent.connect('world_entered', self, '_on_world_entered')


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_accept'):
		HudEvent.emit_signal('hud_accept_pressed')


func _on_world_entered():
	world_entered = true
	_dialog.show()
