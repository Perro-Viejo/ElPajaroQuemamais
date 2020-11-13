extends Control

var _intro_wrapper := '[center][wave]%s[/wave][/center]'
var _intro_format := 'EPISODE_%d_INTRO'

onready var _overlay: ColorRect = find_node('Overlay')
onready var _episode_intro: RichTextLabel = find_node('EpisodeIntro')

func _ready() -> void:
	WorldEvent.connect('episode_started', self, '_hide_curtain')
	WorldEvent.connect('episode_ended', self, '_show_curtain')
	DialogEvent.connect('curtain_requested', self, '_show_for_dialog')
	HudEvent.connect('curtain_toggle_requested', self, '_toggle_curtain')
	
	_overlay.hide()
	_episode_intro.hide()

func _hide_curtain() -> void:
	_episode_intro.clear()
	var tr_code: String = _intro_format % Data.get_data(Data.EPISODE)
	_overlay.show()
	_episode_intro.show()
	_episode_intro.append_bbcode(_intro_wrapper % tr(tr_code))
	DialogEvent.emit_signal('subs_requested', tr_code)
	yield(get_tree().create_timer(3.0), 'timeout')
	_episode_intro.hide()
	DialogEvent.emit_signal('subs_done')
	SoundManager.play_se('ui_transition_circle_out')
	$AnimationPlayer.play('show_scene')
	yield($AnimationPlayer, 'animation_finished')
	_overlay.hide()
	GuiEvent.emit_signal('curtain_hidden')


func _show_curtain() -> void:
	_overlay.show()
	SoundManager.play_se('ui_transition_circle_in')
	$AnimationPlayer.play_backwards('show_scene')
	yield($AnimationPlayer, 'animation_finished')
	_episode_intro.clear()
	GuiEvent.emit_signal('curtain_shown')


func _show_for_dialog(tr_code: String) -> void:
	_overlay.show()
	$AnimationPlayer.play_backwards('show_scene')
	SoundManager.play_se('ui_transition_circle_in')
	yield($AnimationPlayer, 'animation_finished')
	_episode_intro.clear()
	_episode_intro.show()
	_episode_intro.append_bbcode(_intro_wrapper % tr(tr_code))
	DialogEvent.emit_signal('subs_requested', tr_code)
	yield(get_tree().create_timer(3.0), 'timeout')
	_episode_intro.hide()
	DialogEvent.emit_signal('subs_done')
	DialogEvent.emit_signal('dialog_continued')
	$AnimationPlayer.play('show_scene')
	SoundManager.play_se('ui_transition_circle_out')
	yield($AnimationPlayer, 'animation_finished')
	_overlay.hide()

func _toggle_curtain() -> void:
	_overlay.visible = !_overlay.visible
