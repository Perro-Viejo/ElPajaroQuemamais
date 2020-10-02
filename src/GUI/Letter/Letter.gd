extends Control

var _spanish_text := ''
var _english_text := ''
var _in_spanish := true

func _ready() -> void:
#	_spanish_text = tr($TextWrapper/Label.text)
#	TranslationServer.set_locale('en')
#	_english_text = tr($TextWrapper/Label.text)
#	TranslationServer.set_locale('es')
	
	self.connect('visibility_changed', self, '_play_animation')
	$Overlay.connect('gui_input', self, '_on_gui_input')
	$EnglishButton.connect('pressed', self, '_toggle_language')


func _toggle_language() -> void:
	_in_spanish = !_in_spanish
#	$TextWrapper/Label.text = _spanish_text if _in_spanish else _english_text
	TranslationServer.set_locale('es' if _in_spanish else 'en')


func _on_gui_input(event: InputEvent) -> void:
	var mouse_event: = event as InputEventMouseButton
	if mouse_event \
		and mouse_event.button_index == BUTTON_LEFT \
		and mouse_event.pressed:
			TranslationServer.set_locale('es')
			$AnimationPlayer.play('show_letter', -1.0, -2.0, true)
			yield($AnimationPlayer, 'animation_finished')
			hide()


func _play_animation() -> void:
	if visible:
		$AnimationPlayer.play('show_letter')
	else:
		DialogEvent.emit_signal('dialog_requested', 'Ep1Sc4')
