extends Node

signal SIXTEENTH
signal SYNC

enum TICK_VALUE {REDONDA, BLANCA, NEGRA, CORCHEA, SEMICORCHEA}
export (TICK_VALUE) var tick_value
#var for counting inside the division
var gen_count = 0


export(float) var time_signature_top = 4.0
export(float) var time_signature_bottom = 4.0
export(float) var  bpm = 136.0

#var beat_count
var beat_interval
var current_bar
#var current_measure

var downbeat
var sixteenth_time = 0.0
var current_time = 0
var current_beat = 1

var playing = true

func _ready():
	downbeat = time_signature_top*time_signature_bottom
	beat_interval = 60.0 / bpm * 4.0 / float(time_signature_bottom)
	sixteenth_time = beat_interval/4.0
	start()
#	print (current_time, " time to sixteenth: ", sixteenth_time)

func _process(delta):
	if !playing: return
	if playing and current_time == 0 and current_beat == 1:
		emit_signal('SYNC', delta)
	current_time += delta
	var next_beat = int((current_time+delta/2)/sixteenth_time)
	current_beat += next_beat
	if current_beat > downbeat:
		current_beat -= downbeat
		current_bar += 1

	if next_beat >= 1:
		current_time = current_time - (next_beat * sixteenth_time)
		#print('the sixteenth, remain ', current_time)
#		emit_signal('SIXTEENTH', current_bar, current_beat)
		if current_beat == 1:
			AudioEvent.emit_signal("bar_started", current_bar)
#			$Up.play()
			gen_count = 0
		else:
			if tick_value == TICK_VALUE.SEMICORCHEA:
				AudioEvent.emit_signal("sixteenth_ticked", current_bar)
#				$Down.play()
			if tick_value == TICK_VALUE.CORCHEA:
				if gen_count == 1:
					AudioEvent.emit_signal("eight_ticked", current_bar)
#					$Down.play()
					gen_count = 0
				else:
					gen_count += 1
			if tick_value == TICK_VALUE.NEGRA:
				if gen_count == 3:
					AudioEvent.emit_signal("quarter_ticked", current_bar)
#					$Down.play()
					gen_count = 0
				else:
					gen_count += 1
			if tick_value == TICK_VALUE.BLANCA:
				if gen_count == 7:
					AudioEvent.emit_signal("half_ticked", current_bar)
#					$Down.play()
					gen_count = 0
				else:
					gen_count += 1
			if tick_value == TICK_VALUE.REDONDA:
				pass
	
	
func start():
	playing = true
	current_bar = 1
	current_time = 0
	current_beat = 0
