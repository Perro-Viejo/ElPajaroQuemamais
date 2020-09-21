class_name CharacterFrame
extends CanvasLayer

var _offset := Vector2.ZERO

onready var _cont := $Container
onready var _bg := find_node('Background')
onready var _char := find_node('Character')
onready var _defaults := {
	character = _char.texture
}

func _ready() -> void:
	var _bg_size: Vector2 = _bg.get_rect().size
	_offset = Vector2(_bg_size.x / 2, _bg_size.y + 12)

	_cont.hide()


func dialog_started() -> void:
	_cont.show()


func dialog_finished() -> void:
	_cont.hide()
	_char.texture = _defaults.character
	_char.hframes = 1


func set_character(node: Actor, emotion: String) -> void:
	_cont.rect_position = Utils.get_screen_coords_for(node) - _offset
	_char.texture = node.expressions
	_char.hframes = 2
	_char.frame = 0
	if node.expressions_map.has(emotion):
		_char.frame = node.expressions_map[emotion]

	_cont.show()
