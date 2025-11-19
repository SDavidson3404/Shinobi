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

func _ready():
	# If initialized, do nothing
	if init:
		return
	init = true # Set initialized to true
	# If not connected, connect to scene manager to get changed scene signal
	if not SceneManager.is_connected("changed_scene", Callable(self, "_on_scene_changed")):
		SceneManager.connect("changed_scene", Callable(self, "_on_scene_changed"))

# ======= SCENE CHANGED =======
# Function for when scene is changed, load skills
func _on_scene_changed(): load_levels_state()

func save_skills():
	# Set save data as variable
	var save_data = {
		"levels" : levels_completed
	}
	# Set json text as variable
	var json = JSON.stringify(save_data)
	# Save file as variable
	var file = FileAccess.open("user://levels.json", FileAccess.ModeFlags.WRITE)
	# If file valid:
	if file:
		file.store_string(json) # Write save to file
		file.close() # Close file
		
# ======== LOAD ==========
# Function to load from file
func load_levels_state():
	# Set the skills first
	load_levels()
	# Set file path to variable
	var file_path = "user://levels.json"
	# If file exists
	if FileAccess.file_exists(file_path):
		# Open file to read
		var file = FileAccess.open(file_path, FileAccess.ModeFlags.READ)
		# If file is valid
		if file:
			# Get text as variable
			var text = file.get_as_text()
			file.close()
			# Write into new JSON as readable format
			var json = JSON.new()
			# If JSON text is valid
			if json.parse(text) == OK:
				# Save data as variable
				var data = json.get_data()
				# Load skills into variable
				var saved_levels = data.get("levels", {})
				# For skill in saved skills:
				for key in saved_levels.keys():
					# If skill is unlocked:
					if levels_completed.has(key):
						# Update skill in dictionary to say is unlocked
						levels_completed[key] = saved_levels[key]
