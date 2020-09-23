class_name CharacterFrame
extends CanvasLayer

export var appear_time := 0.3

var _offset := Vector2.ZERO

onready var _cnt := $Container
onready var _bg: TextureRect = find_node('Background')
onready var _char: Sprite = find_node('Character')
onready var _defaults := {
	character = _char.texture
}
onready var _continue: TextureRect = find_node('Continue')

func _ready() -> void:
	var _bg_size: Vector2 = _bg.get_rect().size
	_offset = Vector2(_bg_size.x / 2, _bg_size.y + 12)

	_cnt.hide()
	_continue.rect_scale = Vector2.ZERO


func dialog_started() -> void:
	_cnt.show()


func dialog_finished() -> void:
	_cnt.hide()
	_continue.hide()

	# Poner la textura por defecto (la sombra de...)
	_char.texture = _defaults.character
	_char.hframes = 1


func set_character(node: Actor, emotion: String) -> void:
	_continue.rect_scale = Vector2.ZERO

	_cnt.rect_position = Utils.get_screen_coords_for(node) - _offset
	_char.texture = node.expressions
	_char.hframes = 2
	_char.frame = 0

	if node.expressions_map.has(emotion):
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
	AudioEvent.emit_signal("play_requested","UI", "button_pop")
	$Tween.interpolate_property(
		_continue, 'rect_scale',
		Vector2.ZERO, Vector2.ONE,
		0.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT
	)
	$Tween.start()
