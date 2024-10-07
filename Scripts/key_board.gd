extends VBoxContainer


var typed_word = ""
var key_buttons_pressed = []


func text_changed():
	get_parent().change_word_ui()
