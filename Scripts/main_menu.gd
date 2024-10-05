extends Node


var particle_words = [
	"آسمان",
	"خانه",
	"سبز",
	"آبی",
	"چوب",
	"کتاب"
]


@onready var settings_scene = load("res://Scenes/settings_scene.tscn")
@onready var levels_scene = load("res://Scenes/levels.tscn")
@onready var main_scene = load("res://Scenes/main_scene.tscn")
@onready var shop_scene : PackedScene
@onready var daily_button = $VBoxContainer2/HBoxContainer/DailyButton
const green_disabled = preload("res://green_daily_button_disabled.tres")
const red_disabled = preload("res://red_daily_button_disabled.tres")


func _ready():
	for particle in get_tree().get_nodes_in_group("WordParticle"):
		set_particle_word(particle)
	for pair in Word.daily_words_done:
		if Word.day == pair[0]:
			daily_button.disabled = pair[1]
			if pair[1] and pair[2]:
				daily_button.add_theme_stylebox_override("disabled", green_disabled)
			elif pair[1]:
				daily_button.add_theme_stylebox_override("disabled", red_disabled)
			break


func set_particle_word(particle : CPUParticles2D):
	particle.get_child(0).get_child(0).text = Word.words_list.pick_random()


func _on_start_button_pressed():
	SceneManager.change_scene(main_scene)
	Word.set_gamemode(Word.GameModes.Endless)
	print("RST")


func _on_shop_button_pressed():
	SceneManager.change_scene(shop_scene)


func _on_levels_button_pressed():
	Word.set_gamemode(Word.GameModes.Levels)
	SceneManager.change_scene(levels_scene)


func _on_daily_button_pressed():
	Word.set_gamemode(Word.GameModes.Daily)
	SceneManager.change_scene(main_scene)


func _on_settings_button_pressed():
	SceneManager.change_scene(settings_scene)


func _on_quit_button_pressed():
	get_tree().quit()
