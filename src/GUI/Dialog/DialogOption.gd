class_name DialogOption
extends Button

export(
	String,
	'Quemamais', 'Ana María', 'Rico', 'Lupe', 'Mamá Is'
) var voice = 'Quemamais'

onready var defaults := {
	pos = rect_position
}
