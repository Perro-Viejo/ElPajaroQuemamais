extends Node

signal character_spoke(character, message, time_to_disappear, emotion)
signal dialog_event(playing, countdown, duration)
signal dialog_requested(dialog_name)
signal dialog_continued
signal dialog_skipped
signal dialog_finished(dialog_name)
signal dialog_paused
signal line_triggered(character_name, text, time, emotion)
signal dialog_menu_requested(options)
signal dialog_option_clicked(option_dic)
signal dialog_menu_updated(cfg)
signal dialog
signal moved_to_coordinate(character_name, coordinate, final_direction)
signal moved_to_reference(character_name, room, reference_node, final_direction)
signal subs_requested(tr_code)
signal subs_done
signal curtain_requested(text)
signal scene_setup_requested(rules)
