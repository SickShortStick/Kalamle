extends Node


var music_bus_name = "Music"
var music_bus_index


var sfx_bus_name = "SFX"
var sfx_bus_index


@onready var music_slider = $VBoxContainer/VBoxContainer/MusicSlider
@onready var sfx_slider = $VBoxContainer/VBoxContainer/SFXSlider


var main_menu = load("res://Scenes/main_menu.tscn")


func _ready():
	music_bus_index = AudioServer.get_bus_index(music_bus_name)
	sfx_bus_index = AudioServer.get_bus_index(sfx_bus_name)
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(Word.music_volume_value))
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(Word.sfx_volume_value))
	music_slider.value = 1 - Word.music_volume_value
	sfx_slider.value = 1 - Word.sfx_volume_value


func _on_music_slider_value_changed(value):
	AudioServer.set_bus_volume_db(music_bus_index, linear_to_db(1 - value))
	Word.music_volume_value = 1 - value


func _on_back_button_pressed():
	SceneManager.change_scene(main_menu)


func _on_music_slider_drag_ended(value_changed):
	SaveManager.save_data()


func _on_sfx_slider_value_changed(value):
	AudioServer.set_bus_volume_db(sfx_bus_index, linear_to_db(1 - value))
	Word.sfx_volume_value = 1 - value


func _on_sfx_slider_drag_ended(value_changed):
	SaveManager.save_data()
