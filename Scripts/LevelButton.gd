extends PanelContainer
class_name LevelButton


@export var button_index : int
var game_scene = load("res://Scenes/main_scene.tscn")
@onready var button = $MarginContainer/Button
@onready var color_rect = $ColorRect
var is_completed := false
@onready var energy_notif = $"../../../../../EnergyNotif"


func _on_button_pressed():
	if Word.energy > 0:
		Word.set_game_word(button_index)
		Word.energy -= 1
		await SceneManager.change_scene(game_scene)
	else:
		energy_notif.show()
		var energy_notif_tween = get_tree().create_tween()
		energy_notif_tween.tween_property(energy_notif, "modulate", Color("ffffff00"), 1.5).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
		await energy_notif_tween.finished
		energy_notif.hide()
		energy_notif.modulate = Color.WHITE


func set_button_properties(button_text: String, level_index : int):
	button.text = button_text
	button_index = level_index + 1


func level_complete():
	color_rect.show()


func level_incomplete():
	color_rect.hide()
