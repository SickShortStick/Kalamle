extends Node


@onready var main_menu_scene = load("res://Scenes/main_menu.tscn")
@onready var levels_scene = load("res://Scenes/levels.tscn")
@onready var back_button_scene : PackedScene


@export var word : String = ""
var high_score := 0
var max_timer_seconds = 60
var guessed_times : int = 0
var guessed_word : String = ""
var guessed_words : Array
var row : int = 0
var col : int = 0
var game_ended = false
var score := 0


enum GameModes {
	Endless,
	Levels,
	Daily
}


var current_gamemode


var words : Array
var guess_word_letters_count = []
var word_letters_count = []
var word_letters = []
var word_letters_count_copy : Array
var persian_alphabet = [
	'ا', 'ب', 'پ', 'ت', 'ث', 'ج', 'چ', 'ح', 'خ', 'د', 'ذ', 'ر', 'ز', 'ژ', 'س', 'ش', 'ص', 'ض', 'ط', 'ظ', 'ع', 'غ', 'ف', 'ق', 'ک', 'گ', 'ل', 'م', 'ن', 'و', 'ه', 'ی', 'آ']


@onready var time_label = $TimeLabel
@export var correct_color : Color
@export var incorrect_color : Color
@export var in_word_color : Color
@onready var v_box_container = $VBoxContainer
@onready var word_text = $Panel/WordText
@onready var icon = $HBoxContainer/RetryButton/TextureRect
@onready var retry_button = $HBoxContainer/RetryButton
@onready var win_panel_container = $WinPanelContainer
@onready var score_label = $WinPanelContainer/MarginContainer/VBoxContainer/PanelContainer/HBoxContainer2/ScoreLabel
@onready var win_label = $WinPanelContainer/MarginContainer/VBoxContainer/PanelContainer/WinLabel
@onready var win_panel_retry_button = $WinPanelContainer/MarginContainer/VBoxContainer/HBoxContainer/WinPanelRetryButton
@onready var win_panel_main_menu_button = $WinPanelContainer/MarginContainer/VBoxContainer/HBoxContainer/WinPanelMainMenuButton
@onready var next_level_button = $WinPanelContainer/MarginContainer/VBoxContainer/HBoxContainer/NextLevelButton
@onready var previous_level_button = $WinPanelContainer/MarginContainer/VBoxContainer/HBoxContainer/PreviousLevelButton
@onready var word_label = $WinPanelContainer/MarginContainer/VBoxContainer/PanelContainer/WordLabel
@onready var timer = $Timer
@onready var timer_slider = $PanelContainer/HBoxContainer/TimerSlider
@onready var score_label_ui = $ScoreLabel
@onready var error_container = $ErrorContainer
@onready var dimmer = $Dimmer
@onready var high_score_label = $WinPanelContainer/MarginContainer/VBoxContainer/PanelContainer/HBoxContainer2/HighScoreLabel
@onready var music_player = $MusicPlayer


func _ready():
	var music_tween = get_tree().create_tween()
	music_tween.tween_property(music_player, "volume_db", 0, 2).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	set_up_grid()
	match Word.current_gamemode:
		Word.GameModes.Endless:
			set_gamemode(GameModes.Endless)
		Word.GameModes.Levels:
			set_gamemode(GameModes.Levels)
		Word.GameModes.Daily:
			set_gamemode(GameModes.Daily)
	set_up_game_ui()
	score_label_ui.text = str(score)
	match current_gamemode:
		GameModes.Endless:
			Word.set_game_word()
		GameModes.Daily:
			Word.set_game_word()
			word = Word.game_word
			if Word.day == Word.last_day:
				guessed_words = Word.daily_guessed_words
				guessed_times = Word.daily_guessed_words.size()
				create_word_letters_count()
				word_letters_count_copy = word_letters_count.duplicate(true)
				print(word)
				for w in Word.daily_guessed_words:
					guessed_word = w
					col = 0
					for letter_index in 5:
						var row_container = v_box_container.get_child(row)
						var letter_label = row_container.get_child(4 - col).get_child(0)
						letter_label.text = w[letter_index]
						col += 1
					await check_for_correct_letter()
					await check_for_in_word_letter()
					row += 1
			else:
				Word.daily_guessed_words.clear()
		_:
			pass
	high_score = Word.high_score
	word = Word.game_word
	create_word_letters_count()
	print(word_letters_count)
	word_text.grab_focus()


func _process(delta):
	time_label.text = Time.get_time_string_from_system()
	if timer.time_left > max_timer_seconds:
		timer_slider.value = timer_slider.max_value - 1
		timer.start(max_timer_seconds)
	else:
		timer_slider.value = timer.time_left * 60
	if Input.is_action_just_pressed("Enter") and len(guessed_word) == 5:
		var word_is_in_persian = true
		for letter in guessed_word:
			if letter not in persian_alphabet:
				word_is_in_persian = false
		match current_gamemode:
			GameModes.Daily:
				if word_is_in_persian and guessed_word in Word.words_list and guessed_word not in Word.daily_guessed_words:
					guess()
				else:
					error_container.show()
					var invis_tween = get_tree().create_tween()
					invis_tween.tween_property(error_container, "modulate", Color("ffffff00"), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
					await invis_tween.finished
					error_container.modulate = Color.WHITE
					error_container.hide()
			_:
				if word_is_in_persian and guessed_word in Word.words_list and guessed_word not in guessed_words:
					guess()
				else:
					error_container.show()
					var invis_tween = get_tree().create_tween()
					invis_tween.tween_property(error_container, "modulate", Color("ffffff00"), 1).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
					await invis_tween.finished
					error_container.modulate = Color.WHITE
					error_container.hide()


func set_up_grid():
	for r in 6:
		var row_container = v_box_container.get_child(r)
		for c in 5:
			var letter_label = row_container.get_child(c).get_child(0)
			letter_label.text = " "
			letter_label.z_index = 2
			var color_rect = ColorRect.new()
			letter_label.add_sibling(color_rect)
			color_rect.color.a = 0


func set_gamemode(new_gamemode : GameModes):
	current_gamemode = new_gamemode


func create_word_letters_count():
	word_letters_count.clear()
	word_letters = word.split()
	for letter in word_letters:
		var letter_is_in_count = false
		if word_letters_count.is_empty():
			word_letters_count.append_array([[letter, 1]])
		else :
			var index = 0
			for letter_array in word_letters_count:
				if letter == letter_array[0]:
					word_letters_count[index][1] = word_letters_count[index][1] + 1
					letter_is_in_count = true
				index += 1
			if not letter_is_in_count:
				word_letters_count.append_array([[letter, 1]])


func set_up_game_ui():
	score_label_ui.text = "0"
	match current_gamemode:
		GameModes.Levels:
			retry_button.disabled = true
			back_button_scene = levels_scene
		GameModes.Endless:
			timer.start()
			timer_slider.value = timer_slider.max_value
			retry_button.disabled = false
			back_button_scene = main_menu_scene
		GameModes.Daily:
			retry_button.disabled = true
			back_button_scene = main_menu_scene


func guess():
	if not game_ended:
		timer.paused = true
		word_letters_count_copy = word_letters_count.duplicate(true)
		word_text.editable = false
		if guessed_times <= 5:
			guessed_times += 1
			await check_for_correct_letter()
			await check_for_in_word_letter()
		word_text.editable = true
		if guessed_word == word:
			correct_word()
		elif guessed_times == 6:
			game_ended = true
			lose()
		else:
			row += 1
		word_text.text = ""
		match current_gamemode:
			GameModes.Daily:
				guessed_words.append(guessed_word)
				if Word.daily_guessed_words.size() < guessed_words.size():
					Word.daily_guessed_words = guessed_words
				SaveManager.save_data()
			_:
				guessed_words.append(guessed_word)
		guessed_word = ""
		if current_gamemode == GameModes.Endless:
			timer.start(timer.time_left + 2)
		timer.paused = false
	word_text.grab_focus()


func check_for_correct_letter():
	var i : int = 0
	var index = 0
	for letter in guessed_word:
		var color_tween = get_parent().create_tween()
		var color_rect : ColorRect = v_box_container.get_child(row).get_child(4 - i).get_child(1)
		color_rect.show_behind_parent = true
		if letter == word[i]:
			color_tween.tween_property(color_rect, "color", correct_color, 0.3)
			await color_tween.finished
			var pair_index = 0
			for pair in word_letters_count_copy:
				if letter == pair[0]:
					word_letters_count_copy[pair_index][1] -= 1
					break
				pair_index += 1
		i += 1


func check_for_in_word_letter():
	var ii = 0
	for letter in guessed_word:
		var color_tween = get_parent().create_tween()
		var color_rect : ColorRect = v_box_container.get_child(row).get_child(4 - ii).get_child(1)
		color_rect.show_behind_parent = true
		if letter in word:
			var pair_index = 0
			for pair in word_letters_count_copy:
				if letter == pair[0]:
					if pair[1] > 0 and letter != word[ii]:
						word_letters_count_copy[pair_index][1] -= 1
						color_tween.tween_property(color_rect, "color", in_word_color, 0.3)
						await color_tween.finished
						break
					elif letter != word[ii]:
						color_tween.tween_property(color_rect, "color", incorrect_color, 0.3)
						await color_tween.finished
				pair_index += 1
		else :
			color_tween.tween_property(color_rect, "color", incorrect_color, 0.3)
			await color_tween.finished
		ii += 1


func lose():
	game_ended = true
	win_label.text = "باخت!"
	win_label.add_theme_color_override("font_color", Color.RED)
	word_text.release_focus()
	match current_gamemode:
		GameModes.Endless:
			score_label.show()
			score_label.text = "امتیاز\n" + str(score)
			word_label.text = word
			word_label.show()
			previous_level_button.hide()
			next_level_button.hide()
			win_panel_retry_button.show()
			if score > high_score:
				high_score = score
				Word.set_high_score(high_score)
			high_score_label = "رکورد\n" + str(high_score)
		GameModes.Levels:
			word_label.hide()
			score_label.hide()
			if Word.level > 1:
				previous_level_button.show()
			else:
				previous_level_button.hide()
			previous_level_button.show()
			next_level_button.hide()
		GameModes.Daily:
			Word.daily_words_done.append([Word.day, true, false])
			win_panel_retry_button.hide()
			previous_level_button.hide()
			next_level_button.hide()
	score = 0
	win_panel_main_menu_button.show()
	win_panel_container.show()
	dimmer.show()
	SaveManager.save_data()


func correct_word():
	match current_gamemode:
		GameModes.Levels:
			Word.add_completed_level()
			game_ended = true
			score_label.hide()
			win_label.add_theme_color_override("font_color", Color("1fd655"))
			dimmer.show()
			win_label.text = "برد!"
			win_panel_retry_button.hide()
			Word.add_completed_level()
			if Word.level < Word.max_level_count:
				next_level_button.show()
			else:
				next_level_button.hide()
			if Word.level > 1:
				previous_level_button.show()
			else:
				previous_level_button.hide()
			win_panel_container.show()
		GameModes.Endless:
			score += 1
			score_label_ui.text = str(score)
			timer.start(timer.time_left + 7)
			word = Word.set_game_word()
			set_up_game_vars()
		GameModes.Daily:
			Word.daily_words_done.append([Word.day, true, true])
			win_panel_container.show()
			dimmer.show()
			win_panel_main_menu_button.show()
			win_panel_retry_button.hide()
			previous_level_button.hide()
			next_level_button.hide()


func clear_letters():
	for r in 6:
		var row_container = v_box_container.get_child(r)
		for c in 5:
			var letter_label = row_container.get_child(c).get_child(0)
			letter_label.text = " "
			var color_rect = row_container.get_child(c).get_child(1)
			color_rect.color.a = 0
	row = 0
	col = 0


func set_up_game_vars():
	guessed_times = 0
	game_ended = false
	word_text.text = ""
	word = Word.game_word
	word_text.grab_focus()
	guessed_words.clear()
	create_word_letters_count()
	clear_letters()


func _on_word_text_text_changed(new_text):
	if not game_ended:
		guessed_word = new_text
		col = 0
		for letter_index in 5:
			var row_container = v_box_container.get_child(row)
			var letter_label = row_container.get_child(4 - col).get_child(0)
			letter_label.text = new_text[letter_index] if len(new_text) > letter_index else " "
			col += 1


func _on_retry_pressed():
	word = Word.set_game_word()
	icon.position += Vector2(0, 15)
	dimmer.hide()
	win_panel_container.hide()
	timer.start(max_timer_seconds)
	set_up_game_vars()


func _on_retry_button_up():
	icon.position -= Vector2(0, 15)


func _on_back_button_pressed():
	SceneManager.change_scene(back_button_scene)


func _on_next_level_button_pressed():
	Word.set_game_word(Word.level + 1)
	set_up_game_vars()
	win_panel_container.hide()
	dimmer.hide()


func _on_previous_level_button_pressed():
	Word.set_game_word(Word.level - 1)
	set_up_game_vars()
	win_panel_container.hide()
	dimmer.hide()


func _on_main_menu_button_pressed():
	match current_gamemode:
		GameModes.Levels:
			SceneManager.change_scene(levels_scene)
		GameModes.Endless, GameModes.Daily:
			SceneManager.change_scene(main_menu_scene)


func _on_win_panel_retry_button_pressed():
	word = Word.set_game_word()
	win_panel_container.hide()
	dimmer.hide()
	timer.start(max_timer_seconds)
	set_up_game_vars()


func _on_timer_timeout():
	lose()
