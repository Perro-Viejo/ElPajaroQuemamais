class_name DialogMenu
extends VBoxContainer
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Variables ░░░░
signal option_hovered(opt)
signal option_left
signal test_option_clicked

export(PackedScene) var option
export var tween_path: NodePath

var _tween_ref: Tween = null

var current_options := []
# ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░ Funciones ░░░░
func _ready() -> void:
	_tween_ref = get_node(tween_path) as Tween

	hide()


func create_options(options := [], autoshow := false) -> void:
	if options.empty():
		if not current_options.empty():
			show_options()
		return

	current_options = options
	for opt in options:
		var btn: Button = option.instance() as Button
		# btn.text = opt.line
		btn.text = tr(opt.tr_code)
		btn.voice = opt.voice
		btn.hint_tooltip = 'Con la voz de: %s' % btn.voice
		
		btn.connect('pressed', self, '_on_option_clicked', [opt])
		btn.connect('mouse_entered', self, '_on_option_hover', [btn, true])
		btn.connect('mouse_exited', self, '_on_option_hover', [btn, false])
		btn.connect('focus_entered', self, '_on_option_hover', [btn, true])
		btn.connect('focus_exited', self, '_on_option_hover', [btn, false])

		add_child(btn)

		if opt.has('show') and not opt.show:
			opt.show = false
			btn.hide()
		else:
			opt.show = true

	if autoshow: show_options()


func remove_options() -> void:
	if not current_options.empty():
		current_options.clear()

		for btn in get_children():
			remove_child(btn as Button)
			(btn as Button).queue_free()
		hide()


func update_options(updates_cfg := {}) -> void:
	if not updates_cfg.empty():
		var idx := 0
		for btn in get_children():
			btn = (btn as Button)
			var id := String(btn.get_index())
			if updates_cfg.has(id):
				if not updates_cfg[id]:
					current_options[idx].show = false
					btn.hide()
				else:
					current_options[idx].show = true
					btn.show()
			if btn.is_in_group('FocusGroup'):
				btn.remove_from_group('FocusGroup')
				btn.remove_from_group('DialogMenu')
				GUIManager.gui_collect_focusgroup()
			idx+= 1


func show_options() -> void:
	# Establecer cuál será la primera opción a seleccionar cuando se presione
	# una flecha del teclado
	SectionEvent.in_dialog = true
	for btn in get_children():
		if btn.visible:
			btn.add_to_group('FocusGroup')
			btn.add_to_group('DialogMenu')
			GUIManager.gui_collect_focusgroup()
			break

	show()


func _on_option_clicked(opt: Dictionary) -> void:
	SectionEvent.in_dialog = false
	hide()
	DialogEvent.emit_signal('dialog_option_clicked', opt)


func _on_option_hover(btn: DialogOption, hover: bool) -> void:
	_tween_ref.interpolate_property(
		btn, 'rect_position:x',
		btn.defaults.pos.x if hover else btn.defaults.pos.x + 16,
		btn.defaults.pos.x + 16 if hover else btn.defaults.pos.x,
		0.2, Tween.TRANS_SINE, Tween.EASE_OUT
	)
	_tween_ref.start()
	
	if hover:
		AudioEvent.emit_signal('play_requested', 'UI', 'move')
		emit_signal('option_hovered', btn)
	else:
		emit_signal('option_left')

func _test() -> void:
	var voices := ['ana_maría', 'rico', 'lupe', 'quemamais']
	for _btn in get_children():
		var btn: Button = _btn
		btn.connect('pressed', self, '_on_test_option_clicked', [btn])
		btn.connect('mouse_entered', self, '_on_option_hover', [btn, true])
		btn.connect('mouse_exited', self, '_on_option_hover', [btn, false])
		btn.connect('focus_entered', self, '_on_option_hover', [btn, true])
		btn.connect('focus_exited', self, '_on_option_hover', [btn, false])
		btn.voice = voices.pop_front()
		btn.hint_tooltip = 'Con la voz de: %s' % btn.voice

func _on_test_option_clicked(opt: Button) -> void:
	emit_signal('test_option_clicked', opt)
