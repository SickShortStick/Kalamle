extends VBoxContainer


var typed_word = ""
var key_buttons_pressed = []


@onready var keyboard_sound = $"../KeyboardSound"


func text_changed():
	get_parent().change_word_ui()


func play_keyboard_sound():
	keyboard_sound.volume_db = randf_range(0, 4)
	keyboard_sound.pitch_scale = randf_range(1, 1.5)
	keyboard_sound.play()
