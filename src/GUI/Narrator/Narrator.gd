extends Control

var current_tutorial
var first_move = true

func _ready():
	WorldEvent.connect('world_entered', self, '_show_tutorial', [0])
	PlayerEvent.connect('movement_finished', self, '_show_tutorial', [1])
	connect('gui_input', self, '_on_input_event')

func _show_tutorial(tutorial):
	current_tutorial = tutorial
	show()
	match tutorial:
		0:
			$Panel/Tutorials/Movement.show()
			$MovementIcons.show()
		1:
			if first_move:
				$Panel/Tutorials/Interact.show()
				$Panel/Tutorials/Movement.hide()
				$MovementIcons.hide()
				PlayerEvent.disconnect("movement_finished", self, '_show_tutorial')

func _on_input_event(event: InputEvent):
	if event.is_pressed():
		WorldEvent.emit_signal('tutorial_shown', current_tutorial)
		hide()
