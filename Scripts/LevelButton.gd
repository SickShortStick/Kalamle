extends PanelContainer
class_name LevelButton


@export var button_index : int
var game_scene = load("res://Scenes/main_scene.tscn")
@onready var button = $MarginContainer/Button
@onready var color_rect = $ColorRect
var is_completed := false


func _on_button_pressed():
	Word.set_game_word(button_index)
	await SceneManager.change_scene(game_scene)
	#MainScene.word = level_word


func set_button_properties(button_text: String, level_index : int):
	button.text = button_text
	button_index = level_index + 1


func level_complete():
	color_rect.show()


func level_incomplete():
	color_rect.hide()
