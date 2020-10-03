extends Control

var _intro_wrapper := '[center][wave]%s[/wave][/center]'
var _intro_format := 'EPISODE_%d_INTRO'

onready var _overlay: ColorRect = find_node('Overlay')
onready var _episode_intro: RichTextLabel = find_node('EpisodeIntro')

func _ready() -> void:
	WorldEvent.connect('episode_started', self, '_hide_curtain')
	WorldEvent.connect('episode_ended', self, '_show_curtain')
	
	_overlay.hide()
	_episode_intro.hide()

func _hide_curtain() -> void:
	var tr_code: String = _intro_format % Data.get_data(Data.EPISODE)
	_overlay.show()
	_episode_intro.show()
	_episode_intro.append_bbcode(_intro_wrapper % tr(tr_code))
	DialogEvent.emit_signal('subs_requested', tr_code)
	yield(get_tree().create_timer(3.0), 'timeout')
	_episode_intro.hide()
	DialogEvent.emit_signal('subs_done')
	$AnimationPlayer.play('show_scene')
	yield($AnimationPlayer, 'animation_finished')
	_overlay.hide()
	GuiEvent.emit_signal('curtain_hidden')


func _show_curtain() -> void:
	_overlay.show()
	$AnimationPlayer.play_backwards('show_scene')
	yield($AnimationPlayer, 'animation_finished')
	_episode_intro.clear()
	GuiEvent.emit_signal('curtain_shown')
