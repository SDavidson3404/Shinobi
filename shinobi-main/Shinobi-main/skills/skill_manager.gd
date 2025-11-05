extends Node

var skills = {}
var player_points := 15
var init := false

func load_skills():
	skills = {
		"dodge": {"unlocked": false, "prereq": [], "cost": 1},
		"double_jump": {"unlocked": false, "prereq": ["dodge"], "cost": 2},
		"wall_run": {"unlocked": false, "prereq": ["double_jump"], "cost": 3},
		"wall_scramble": {"unlocked": false, "prereq": ["wall_run"], "cost": 4},
		"weapon_throw": {"unlocked": false, "prereq": ["wall_scramble"], "cost": 5},
		"spear_unlock": {"unlocked": false, "prereq": ["dodge"], "cost": 1},
		"dagger_unlock": {"unlocked": false, "prereq": ["spear_unlock"], "cost": 3},
		"burst_mode": {"unlocked": false, "prereq": ["dagger_unlock"], "cost": 5},
		"stamina1": {"unlocked": false, "prereq": ["dodge"], "cost": 1},
		"stamina2": {"unlocked": false, "prereq": ["stamina1"], "cost": 2},
		"stamina3": {"unlocked": false, "prereq": ["stamina2"], "cost": 3},
		"stamina4": {"unlocked": false, "prereq": ["stamina3"], "cost": 4},
		"stamina5": {"unlocked": false, "prereq": ["stamina4"], "cost": 5},
		"health1": {"unlocked": false, "prereq": ["dodge"], "cost": 1},
		"health2": {"unlocked": false, "prereq": ["health1"], "cost": 2},
		"health3": {"unlocked": false, "prereq": ["health2"], "cost": 3},
		"health4": {"unlocked": false, "prereq": ["health3"], "cost": 4},
		"health5": {"unlocked": false, "prereq": ["health4"], "cost": 5},
		"dull_dagger": {"unlocked": false, "prereq": ["dagger_unlock"], "cost": 1},
		"sharp_dagger": {"unlocked": false, "prereq": ["dull_dagger"], "cost": 2},
		"iron_dagger": {"unlocked": false, "prereq": ["sharp_dagger"], "cost": 3},
		"gem_dagger": {"unlocked": false, "prereq": ["iron_dagger"], "cost": 4},
		"buster_dagger": {"unlocked": false, "prereq": ["gem_dagger"], "cost": 5},
		"dull_spear": {"unlocked": false, "prereq": ["spear_unlock"], "cost": 1},
		"sharp_spear": {"unlocked": false, "prereq": ["dull_spear"], "cost": 2},
		"steel_spear": {"unlocked": false, "prereq": ["sharp_spear"], "cost": 3},
		"gilded_spear": {"unlocked": false, "prereq": ["steel_spear"], "cost": 4},
		"the_ultima_spear": {"unlocked": false, "prereq": ["gilded_spear"], "cost": 5},
		"dull_sword": {"unlocked": false, "prereq": ["dodge"], "cost": 1},
		"sharp_sword": {"unlocked": false, "prereq": ["dull_sword"], "cost": 2},
		"forged_sword": {"unlocked": false, "prereq": ["sharp_sword"], "cost": 3},
		"steel_sword": {"unlocked": false, "prereq": ["forged_sword"], "cost": 4},
		"pure_sword": {"unlocked": false, "prereq": ["steel_sword"], "cost": 5},
	}

func can_unlock(id: String) -> bool:
	var skill = skills[id]
	if skill["unlocked"]:
		return false
	if player_points < skill["cost"]:
		return false

	for pre in skill["prereq"]:
		if not skills[pre]["unlocked"]:
			return false
	return true

func unlock(id: String):
	if can_unlock(id):
		skills[id]["unlocked"] = true
		player_points -= skills[id]["cost"]
		save_skills()  # <-- Save immediately after buying

func _on_scene_changed():
	print("DEBUG")
	load_skills()
	load_skills_state()
	skills_loaded.emit()

func _ready():
	if init:
		return
	init = true
	if not SceneManager.is_connected("changed_scene", Callable(self, "_on_scene_changed")):
		SceneManager.connect("changed_scene", Callable(self, "_on_scene_changed"))


func check_unlocked(id: String) -> bool:
	if not skills.has(id):
		return false
	return skills[id]["unlocked"]


func save_skills():
	var save_data = {
		
		"player_points": player_points,
		"save_skills": skills
	}

	var json = JSON.stringify(save_data)  # <-- use JSON.stringify() instead of to_json()
	var file = FileAccess.open("user://test4.json", FileAccess.ModeFlags.WRITE)
	if file:
		file.store_string(json)
		file.close()
		print("Skills saved!")

signal skills_loaded

func load_skills_state():
	load_skills() # ALWAYS populate keys first
	
	var file_path = "user://test4.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
		if file:
			var text = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			if json.parse(text) == OK:
				var data = json.get_data()
				player_points = data.get("player_points", 15)
				var saved_skills = data.get("save_skills", {})
				for key in saved_skills.keys():
					if skills.has(key):
						skills[key]["unlocked"] = saved_skills[key]["unlocked"]
	emit_signal("skills_loaded")



func is_unlocked(skill_id: String) -> bool:
	return skills.has(skill_id) and skills[skill_id]["unlocked"]
