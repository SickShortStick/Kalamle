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
@onready var energy_container = $EnergyContainer


const LIGHTNING_ICON = preload("res://Assets/Sprites/Lightning Icon.png")
const LIGHTNING_EMPTY_ICON = preload("res://Assets/Sprites/Lightning Empty Icon.png")


func _ready():
	Word.in_menu = true
	Word.in_levels = false
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
	change_energy_ui()


func change_energy_ui():
	var energy_icons = energy_container.get_children()
	for i in Word.max_energy:
		if i < Word.energy:
			energy_icons[i].texture = LIGHTNING_ICON
		else :
			energy_icons[i].texture = LIGHTNING_EMPTY_ICON


func set_particle_word(particle : CPUParticles2D):
	particle.get_child(0).get_child(0).text = Word.words_list.pick_random()


func _on_start_button_pressed():
	SceneManager.change_scene(main_scene)
	Word.set_gamemode(Word.GameModes.Endless)


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
