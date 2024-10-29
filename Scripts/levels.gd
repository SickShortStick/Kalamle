extends Control


@onready var grid_container = $PanelContainer/VBoxContainer/MarginContainer/GridContainer
@onready var main_menu = load("res://Scenes/main_menu.tscn")
@onready var energy_container = $EnergyContainer
const LIGHTNING_EMPTY_ICON = preload("res://Assets/Sprites/Lightning Empty Icon.png")
const LIGHTNING_ICON = preload("res://Assets/Sprites/Lightning Icon.png")

@export var max_page_number := 4
var page_number := 0:
	set(new_page_number):
		page_number = clamp(new_page_number, 0, max_page_number)


func _ready():
	Word.in_levels = true
	Word.in_menu = false
	set_level_buttons()
	for particle in get_tree().get_nodes_in_group("WordParticle"):
		set_particle_word(particle)
	change_energy_ui()


func set_level_buttons():
	for i in 20:
		var level_button = grid_container.get_children()[i]
		level_button.set_button_properties(str((i + 1) + page_number * 20), i + page_number * 20)
		if ((i + 1) + page_number * 20) in Word.completed_levels:
			level_button.level_complete()
		else:
			level_button.level_incomplete()


func _on_back_button_pressed():
	SceneManager.change_scene(main_menu)


func change_energy_ui():
	var energy_icons = energy_container.get_children()
	for i in Word.max_energy:
		if i < Word.energy:
			energy_icons[i].texture = LIGHTNING_ICON
		else :
			energy_icons[i].texture = LIGHTNING_EMPTY_ICON


func set_particle_word(particle : CPUParticles2D):
	particle.get_child(0).get_child(0).text = Word.words_list.pick_random()


func _on_previous_button_pressed():
	page_number -= 1
	set_level_buttons()


func _on_next_button_pressed():
	page_number += 1
	set_level_buttons()
