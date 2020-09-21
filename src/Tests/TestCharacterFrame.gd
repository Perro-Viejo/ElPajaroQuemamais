extends Node2D

onready var bdb: BlockingDialogBox = $BlockingDialogBox

func _ready() -> void:
	# _test_bdb()
	pass

func _test_bdb() -> void:
	yield(get_tree().create_timer(3), 'timeout')
	bdb.append_text('Hola amigos', 90)
	bdb.append_text("Immediate, and supports [wave]effects[/wave]\n", 90)
