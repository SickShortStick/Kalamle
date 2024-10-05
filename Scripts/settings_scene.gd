extends Node


var bus_name = "Music"
var bus_index


@onready var music_slider = $VBoxContainer/VBoxContainer/MusicSlider


var main_menu = load("res://Scenes/main_menu.tscn")


func _ready():
	bus_index = AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(Word.music_volume_value))
	music_slider.value = 1 - Word.music_volume_value


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(1 - value))
	Word.music_volume_value = 1 - value


func _on_back_button_pressed():
	SceneManager.change_scene(main_menu)


func _on_music_slider_drag_ended(value_changed):
	SaveManager.save_data()
