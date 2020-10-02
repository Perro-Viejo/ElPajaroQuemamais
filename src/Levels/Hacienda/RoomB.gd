extends "res://src/Levels/Hacienda/Room.gd"

func open_desk() -> void:
	$Desk.frame = 1 if $Desk.frame == 0 else 0
	if Data.get_data(Data.EPISODE) == 1:
		yield(get_tree().create_timer(1), 'timeout')
		DialogEvent.emit_signal('dialog_requested', 'Ep1Sc2')
