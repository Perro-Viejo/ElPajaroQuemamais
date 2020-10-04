extends "res://src/Levels/Hacienda/Room.gd"

func open_desk() -> void:
	AudioEvent.emit_signal("play_requested", "Objects", "drawer_op")
	$Desk.frame = 1 if $Desk.frame == 0 else 0
	if Data.get_data(Data.EPISODE) == 1:
		DialogEvent.emit_signal('dialog_requested', 'Ep1Sc3')
