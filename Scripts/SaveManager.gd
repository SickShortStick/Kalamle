extends Node


var save_path = "user://saved_data"


func _ready():
	#DirAccess.remove_absolute(save_path)
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var saved_dict : Dictionary = file.get_var()
		if saved_dict.size() == 9:
			load_data()
		else:
			save_data()
		print(saved_dict)
	else:
		save_data()


func save_data():
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	Word.last_day = Word.day
	file.store_var({
		"completed_levels" : Word.completed_levels,
		"high_score" : Word.high_score,
		"daily_guessed_words" : Word.daily_guessed_words,
		"daily_words_done" : Word.daily_words_done,
		"last_day" : Word.last_day,
		"music_volume_value" : Word.music_volume_value,
		"sfx_volume_value" : Word.sfx_volume_value,
		"last_unix" : Word.last_unix if Word.last_unix != null else int(Time.get_unix_time_from_system()),
		"energy" : Word.energy
	})
	file.close()


func load_data():
	var file = FileAccess.open("user://saved_data", FileAccess.READ)
	var saved_dict : Dictionary = file.get_var()
	Word.completed_levels = saved_dict.get("completed_levels")
	Word.high_score = saved_dict.get("high_score")
	Word.daily_guessed_words = saved_dict.get("daily_guessed_words")
	Word.daily_words_done = saved_dict.get("daily_words_done")
	Word.last_day = saved_dict.get("last_day")
	Word.music_volume_value = saved_dict.get("music_volume_value")
	Word.sfx_volume_value = saved_dict.get("sfx_volume_value")
	Word.last_unix = saved_dict.get("last_unix")
	Word.energy = saved_dict.get("energy")
	print(saved_dict)
	file.close()
