class_name CharacterFrame
extends CanvasLayer

var _offset := Vector2.ZERO

onready var _cont := $Container
onready var _bg := find_node('Background')

func _ready() -> void:
	var _bg_size: Vector2 = _bg.get_rect().size
	_offset = Vector2(_bg_size.x / 2, _bg_size.y + 12)
	
	_cont.hide()

func dialog_started() -> void:
	_cont.show()

func dialog_finished() -> void:
	_cont.hide()

func set_position(node: Node2D) -> void:
	dialog_started()
	_cont.rect_position = Utils.get_screen_coords_for(node) - _offset

func set_character() -> void:
	pass
