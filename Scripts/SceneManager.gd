extends Node


@onready var tree = get_tree()


func change_scene(next_scene : PackedScene = null):
	print("Working")
	Pattern.get_child(0).set_mouse_filter(0)
	Pattern.play("fade_in")
	await Pattern.animation_finished
	get_tree().change_scene_to_packed(next_scene)
	Pattern.play("fade_out")
	await Pattern.animation_finished
	Pattern.get_child(0).set_mouse_filter(2)
	Engine.time_scale = 1
