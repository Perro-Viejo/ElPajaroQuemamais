extends "res://src/Levels/Hacienda/Room.gd"

func open_desk() -> void:
	SoundManager.play_se('sfx_drawer_open')
	$Desk.frame = 1 if $Desk.frame == 0 else 0
	if Data.get_data(Data.EPISODE) == 1:
		DialogEvent.emit_signal('dialog_requested', 'Ep1Sc3')
	$MusicTrigger.monitoring = true

func grab_journal() -> void:
#	SoundManager.play_se('sfx_grab_journal')
	if Data.get_data(Data.EPISODE) == 4:
		DialogEvent.emit_signal('dialog_requested', 'Ep4Sc2')

