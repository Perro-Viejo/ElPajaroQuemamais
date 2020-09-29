class_name CharacterFrame
extends CanvasLayer

export var appear_time := 0.3

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables privadas ▒▒▒▒
var _offset := Vector2.ZERO

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ variables onready ▒▒▒▒
onready var _cnt := $Container
onready var _bg: TextureRect = find_node('Background')
onready var _char: Sprite = find_node('Character')
onready var _defaults := {
	character = _char.texture
}
onready var _continue: TextureRect = find_node('Continue')

# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos de Godot ▒▒▒▒
func _ready() -> void:
	var _bg_size: Vector2 = _bg.get_rect().size
	_offset = Vector2(_bg_size.x / 2, _bg_size.y + 12)

	_cnt.hide()
	_continue.rect_scale = Vector2.ZERO


# ▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒▒ métodos públicos ▒▒▒▒
func dialog_started() -> void:
	_cnt.show()


func dialog_finished() -> void:
	_cnt.hide()
	_continue.hide()

	# Poner la textura por defecto (la sombra de...)
	_char.texture = _defaults.character
	_char.hframes = 1
	_char.frame = 0


func set_character(node: Actor, emotion: String) -> void:
	_continue.rect_scale = Vector2.ZERO

	_cnt.rect_position = Utils.get_screen_coords_for(node) - _offset
	_char.texture = node.expressions
	_char.offset = node.expressions_offset
	
	var expressions_count := 0
	for val in node.expressions_map.values():
		if val > -1:
			expressions_count += 1
	
	_char.hframes = expressions_count
	_char.frame = 0

	if not emotion:
		# Si no hay emoción, coger cualquiera entre los posibles fotogramas
		randomize()
		_char.frame = randi() % expressions_count
	elif node.expressions_map.has(emotion):
		_char.frame = node.expressions_map[emotion]

	_cnt.show()

	$Tween.interpolate_property(
		_cnt, 'rect_scale',
		Vector2.RIGHT, Vector2.ONE,
		appear_time, Tween.TRANS_QUINT, Tween.EASE_OUT
	)
	$Tween.start()
	AudioEvent.emit_signal("play_requested","UI", "bubble_op")
	yield($Tween, 'tween_completed')


func show_continue() -> void:
	_continue.show()
	AudioEvent.emit_signal("play_requested","UI", "button_pop")
	$Tween.interpolate_property(
		_continue, 'rect_scale',
		Vector2.ZERO, Vector2.ONE,
		0.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	$Tween.start()


func line_finished() -> void:
	$Tween.interpolate_property(
		_cnt, 'rect_scale',
		Vector2.ONE, Vector2.RIGHT,
		0.1, Tween.TRANS_SINE, Tween.EASE_IN
	)
	$Tween.start()
	yield($Tween, 'tween_completed')
