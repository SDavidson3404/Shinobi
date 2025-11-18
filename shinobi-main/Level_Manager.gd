extends Node

var init = false
var levels_completed: Dictionary

func load_levels() -> void:
	levels_completed = {
		"level_1" : false,
		"level_2" : false,
		"level_3" : false,
		"level_4" : false,
		"level_5" : false,
		"level_6" : false
	}
