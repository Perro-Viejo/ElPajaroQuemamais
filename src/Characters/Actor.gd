class_name Actor
extends KinematicBody2D

signal died()

export var dialog_color: Color
export var speed := 300
export var dialog_name := ''
# El spritesheet con las emociones del personaje para que se muestren en el
# cuadro de diálogo
export var expressions: Texture
export var expressions_map := {
	angry = -1,
	excited = -1,
	sad = -1,
	thinking = -1,
	worried = -1
}
export var expressions_offset := Vector2.ZERO

var _in_dialog := false

#onready var inventory = $Inventory
onready var state_machine = $StateMachine
onready var _lower_name := name.to_lower()

var path : = PoolVector2Array()

var velocity = Vector2.ZERO

func _ready():
	if dialog_name:
		_lower_name = dialog_name.to_lower().replace(' ', '_')
	
	DialogEvent.connect('line_triggered', self, '_should_speak')
	
# Called when the node enters the scene tree for the first time.
func speak(text := '', time_to_disappear := 0):
	DialogEvent.emit_signal('character_spoke', self, text, time_to_disappear)

func spoke():
	if _in_dialog:
		DialogEvent.emit_signal('dialog_continued')

func _should_speak(character_name, text, time, emotion) -> void:
	if _lower_name == character_name:
		speak(text, time)
		AudioEvent.emit_signal('dx_requested' , character_name, emotion)
		
func _physics_process(delta):
	
	var direction = Vector2(0,0)
	
	if path.size() > 0:
		var next_position = path[0]
		var distance_to_next_point = position.distance_to(next_position)
		
		if(abs(position.x - next_position.x) <= 1 and abs(position.y - next_position.y) <= 1):
			path.remove(0)
			
		if(distance_to_next_point != 0):
			next_position = position.linear_interpolate(next_position, (speed*delta)/distance_to_next_point)
			
		direction = next_position - position;
		direction.normalized()
		
		move_and_slide(direction * speed * delta)
		
		
