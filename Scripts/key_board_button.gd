extends PanelContainer
class_name KeyBoardButton


@onready var color_rect = $ColorRect
@export var letter := "ب"
@onready var button = $Button


@export var current_button_type = ButtonType.Key


enum ButtonType {
	Key,
	BackSpace,
	Enter
}


func _ready():
	button.text = letter


func turn_blue():
	var color_tween = get_tree().create_tween()
	color_tween.tween_property(color_rect, "color", Color("27374d"), 0.8)


func turn_green():
	var color_tween = get_tree().create_tween()
	color_tween.tween_property(color_rect, "color", Color("1fd655"), 1.5)


func turn_yellow():
	var color_tween = get_tree().create_tween()
	color_tween.tween_property(color_rect, "color", Color("e1bf00"), 1.5)


func turn_gray():
	var color_tween = get_tree().create_tween()
	color_tween.tween_property(color_rect, "color", Color.DARK_GRAY, 1.5)


func _on_button_pressed():
	print("yep")
	var keyboard = get_node("../..")
	var word_line = get_node("../../../Panel/WordText")
	match current_button_type:
		ButtonType.Key:
			if keyboard.key_buttons_pressed.size() < 5:
				keyboard.key_buttons_pressed.append(self)
			word_line.text += letter
			keyboard.text_changed()
		ButtonType.BackSpace:
			if len(word_line.text) > 0:
				word_line.text= word_line.text.erase(len(word_line.text) - 1)
			if keyboard.key_buttons_pressed.size() > 0:
				keyboard.key_buttons_pressed.remove_at(keyboard.key_buttons_pressed.size() - 1)
			keyboard.text_changed()
		ButtonType.Enter:
			Input.action_press("Enter")
			#var i = 0
			#for button in keyboard.key_buttons_pressed:
				#if letter == Word.game_word[i]:
					#turn_green()
				#elif letter in Word.game_word:
					#turn_yellow()
				#else :
					#turn_gray()
				#i += 1
			print("R")
