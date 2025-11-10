extends CharacterBody3D
class_name Player

# ========================
# NODES
# ========================
@onready var orientation: Node3D = $Orientation # Orientation of everything but camera
@onready var aspects: Node3D = $Orientation/aspects # Aspects of the player
@onready var anim_player: AnimationPlayer = $Orientation/aspects/AnimationPlayer # Animations of player
@onready var camera_pivot: Node3D = $CameraPivot # Parent of camera aspects
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D # Camera
@onready var grapple_ray: RayCast3D = $RayCast3D # Raycast for grappling hook
@onready var weapon_holster: Node3D = $"Orientation/aspects/Weapon holster" # Holster for all weapons
@onready var stamina_bar: ProgressBar = $"../UI/StaminaBar" # Stamina Bar on UI
@onready var healthbar: ProgressBar = $"../UI/Healthbar" # Health Bar on UI
@onready var sword: Node3D = $"Orientation/aspects/Weapon holster/Sword" # Player's sword
@onready var spear: Node3D = $"Orientation/aspects/Weapon holster/Spear" # Player's spear
@onready var sprite_3d: Sprite3D = $CameraPivot/Sprite3D # Message to say you picked up collectible
@onready var v_box: VBoxContainer = $CameraPivot/VBoxContainer # Pause Menu
@onready var red: Sprite2D = $"../UI/red" # Red screen for burst mode
@onready var recharged: Label = $"../UI/Recharged" # UI saying burst mode is recharged
@onready var needs: Label = $"../UI/needs" # UI saying burst mode needs to recharge
@onready var game_saved: Label = $"../UI/Game Saved" # UI saying game was saved
@onready var dagger: Node3D = $"Orientation/aspects/Weapon holster/Dagger" # Player's dagger

# ========================
# SAVE
# ========================
var scene_to_save: String = "" # Will change to file that is going to save
var tutorial: String = "res://tutorial.tscn" # Tutorial path
var level_1: String = "res://level_1.tscn" # Level 1 path
var level_2: String = "res://level_2.tscn" # Level 2 path
var level_3: String = "res://level_3.tscn" # Level 3 path

# ==========================
# STATS
# ==========================
@export var SPEED: float = 7.0 # Movement Speed
@export var JUMP_VELOCITY: float = 20.0 # Jump Height
@export var max_stamina: float = 100.0 # Maximum Stamina
@export var stamina_recharge_rate: float = 15.0 # Rate Stamina Recharges
@export var stamina_recharge_delay: float = 0.5 # Delay before recharging
@export var max_health: int = 100 # Max health
var current_stamina: float = max_stamina # Current stamina starts as max
var stamina_recharge_timer: float = 0.0 # Timer for recharge
var health: int = max_health # Current health starts at max
var input_vector: Vector2 = Vector2.ZERO # Movement direction

# ==========================
# MOUSE
# ==========================
@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.01 # Mouse sensitivity
@export var tilt_limit: float = deg_to_rad(75) # Camera limit

# ==========================
# GRAPPLE
# ==========================
@export var grapple_speed: float = 25.0 # Speed of grapple
@export var max_grapple_distance: float = 15.0 # Max distance can grapple
@export var grapple_stop_distance: float = 3.0 # Distance where grapple stops
@export var grapple_cooldown: float = 1.0 # Cooldown between uses
@export var grapple_stamina_cost: float = 50.0 # Stamina cost for grapple
var is_grappling: bool = false # Checks if is grappling
var grapple_point: Vector3 # Point to grapple to

# ==========================
# WEAPON
# ==========================
var weapons: Array[Node3D] = [] # Array of weapons
var current_weapon_index: int = 0 # Current weapon's index
var current_weapon: Node3D = null # Current weapon's node

# ==========================
# JUMP
# ==========================
@export var Max_jumps = 1 # Number of jumps can perform
var gravity := -24.8 # Gravity strength
var Current_jumps = 0 # Number of jumps performed
var can_jump := false

# ==========================
# WALL RUN + CLIMB
# ==========================
@export var WALL_CLIMB_DURATION: float = 1.0 # How long you can climb
@export var WALL_CLIMB_SPEED: float = 10.0 # Speed at which you climb
@export var wall_check_distance: float = 1.0 # Distance to check for wall
const MAX_WALL_RUN_TIME := 1.0 # Max time to wall run
const WALL_RUN_SPEED := 9.0 # Wall run speed
const WALL_RUN_GRAVITY := -5.0 # Gravity during wall run
const WALL_ANGLE_THRESHOLD := 0.9 # Angle of raycasts checking for walls
var is_wall_running := false # Checks if wall running
var wall_run_direction := Vector3.ZERO # Direction of wall run
var wall_run_timer := 0.0 # Timer to check how long player has been wall running
var can_wall_run := false # Checks if wall run is possible
var is_wall_climbing: bool = false # Checks if wall running
var wall_climb_timer: float = 0.0 # Timer to check wall climb time
var climb_wall_normal: Vector3 = Vector3.ZERO # Wall climb location
var can_climb: bool = false # Checks if can climb
var wall_climb_used: bool = false # Checks if climb used during this jump
var wall_run_lockout := false # Adds a cooldown
var wall_run_lockout_time := 0.5 # Time to lock for cooldown
var wall_run_lockout_timer := 0.0 # Timer for cooldown
var last_wall_normal := Vector3.ZERO # I'm not really sure honestly, I think its the location of the wall
var q = PhysicsRayQueryParameters3D.new() # Creates a Raycast to check for walls


# ==========================
# DODGE
# ==========================
@export var dodge_speed: float = 35.0 # Speed of movement during dodge
@export var dodge_duration: float = 0.10 # Duration of movement during dodge
@export var dodge_cooldown: float = 0.6 # Cooldown between dodges
@export var dodge_stamina_cost: float = 25.0 # Stamina cost for dodge
@export var dodge_invincibility_time: float = 0.2 # How long invincibility lasts during dodge
var is_dodging: bool = false # Checks if dodging
var dodge_timer: float = 0.0 # Timer for dodge
var dodge_cooldown_timer: float = 0.0 # Cooldown timer for dodge
var dodge_direction: Vector3 = Vector3.ZERO # Direction of dodge
var invulnerable: bool = false # Checks if invincible
var invuln_timer: float = 0.0 # Timer for invulnerability

# ==========================
# WEAPON THROW
# ==========================
@export var throw_speed: float = 30.0 # Speed at which weapon moves
@export var throw_gravity: float = -9.8 # Gravity applied to weapon
@export var return_speed: float = 40.0 # Return speed of weapon
@export var throw_distance: float = 10.0 # Distance can throw
var thrown_weapon: Node3D = null # Stores thrown weapon
var is_weapon_thrown: bool = false # Checks if weapon is thrown
var throw_velocity: Vector3 = Vector3.ZERO # Throw velocity
var can_throw := false # Checks if can throw
var is_weapon_returning: bool = false # Checks if weapon is returning
var throw_direction: Vector3 = Vector3.ZERO # Direction of throw
var thrown_distance: float = 0.0 # Distance thrown so far
var weapon_original_transform: Transform3D # Original location of weapon before thrown

# ==========================
# COMBAT EFFECTS
# ==========================
var knockback_velocity: Vector3 = Vector3.ZERO # Velocity of knockback
var knockback_decay: float = 10.0 # Decay of knockback over time
var shake_amount: float = 0.0 # Amount shaken
var shake_decay: float = 5.0 # Shake decay

# ==========================
# ETC
# ==========================
var is_paused = false # Checks if paused
var burst_cooldown := false # Checks if cooldown is active on burst

# ========================
# READY
# ========================
# Performs as scene is loaded
func _ready() -> void:
	var current_scene = get_tree().current_scene.name # Gets name of parent node of current scene
	# Saves scene path depending on parent node name
	if current_scene == "Tutorial":
		scene_to_save = tutorial
	elif current_scene == "Level 1":
		scene_to_save = level_1
	elif current_scene == "level 2":
		scene_to_save = level_2
	elif current_scene == "Level_3":
		scene_to_save = level_3
	# Connect signals to functions
	Collectible.connect("collected", Callable(self, "_on_collectible_collected"))
	sword.connect("hit_landed", Callable(self, "_on_sword_hit"))
	spear.connect("hit_landed", Callable(self, "_on_spear_hit"))
	dagger.connect("hit_landed", Callable(self, "_on_dagger_hit"))
	# Captures mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Adds player to group "player"
	add_to_group("player")
	# Adds weapons to weapon list if unlocked
	for child in weapon_holster.get_children():
		if child is Node3D:
			if child.name == "Sword":
				weapons.append(child)
			if child.name == "Spear":
				if SkillManager.check_unlocked("spear_unlock"):
					weapons.append(child)
			if child.name == "Dagger":
				if SkillManager.check_unlocked("dagger_unlock"):
					weapons.append(child)
			child.visible = false
	# Sets current weapon to first weapon
	if weapons.size() > 0:
		current_weapon_index = 0
		current_weapon = weapons[current_weapon_index]
		current_weapon.visible = true
	# Saves Starting location of weapon
	if current_weapon: weapon_original_transform = current_weapon.transform
	# Saves data
	var save_data = {
		"current_level" : scene_to_save,
		"skills" : SkillManager.skills,
		"Points" : SkillManager.player_points
	}
	var file_path = "res://save_game.json"
	var file = FileAccess.open(file_path, FileAccess.ModeFlags.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)  # Convert dictionary to JSON string
		file.store_string(json_string)
		file.close()
		print("Game saved successfully!")
		game_saved.visible = true
		await get_tree().create_timer(1).timeout
		game_saved.visible = false
	else:
		print("Failed to open save file!")
	# Sets max health and stamina based on unlocks
	if SkillManager.check_unlocked("health5"): max_health = 175
	elif SkillManager.check_unlocked("health4"): max_health = 150
	elif SkillManager.check_unlocked("health3"): max_health = 130
	elif SkillManager.check_unlocked("health2"): max_health = 115
	elif SkillManager.check_unlocked("health1"): max_health = 105
	if SkillManager.check_unlocked("stamina5"): max_stamina = 175
	elif SkillManager.check_unlocked("stamina4"): max_stamina = 150
	elif SkillManager.check_unlocked("stamina3"): max_stamina = 130
	elif SkillManager.check_unlocked("stamina2"): max_stamina = 115
	elif SkillManager.check_unlocked("stamina1"): max_stamina = 105
	# Checks if you have Double Jump, Wall Run/Climb, and Weapon Throw
	if SkillManager.check_unlocked("double_jump"): Max_jumps = 2
	can_wall_run = SkillManager.check_unlocked("wall_run")
	can_climb = SkillManager.check_unlocked("wall_scramble")
	can_throw = SkillManager.check_unlocked("weapon_throw")

# ==========================
# INPUT
# ==========================
# Actions when buttons pressed
func _input(event):
	# If escape is pressed, pause or unpause game
	if event.is_action_pressed("ESCAPE"):
		if not is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			v_box.visible = true
			is_paused = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			v_box.visible = false
			is_paused = false
	# If clicking on window while mouse is not captured and game is not paused, capture mouse
	if event.is_action_pressed("click") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if not is_paused: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Swap Weapon if button is pressed
	if event.is_action_pressed("Weapon Swap"): if not is_paused: swap_weapon()
	# Grapple is button pressed
	if Input.is_action_pressed("grapple"): if not is_paused: try_grapple()
	# If clicking, light_attack
	if Input.is_action_just_pressed("click") and current_weapon: if not is_paused: current_weapon.attack(false)
	# If right_click, heavy attack
	if Input.is_action_just_pressed("heavy_attack") and current_weapon: if not is_paused: current_weapon.attack(true)
	# If press dodge and dodge unlocked, dodge
	if Input.is_action_pressed("dodge"):
		if SkillManager.check_unlocked("dodge"):
			if not is_paused:
				try_dodge()
	# If you press space, jump unless wall climbing or can climb
	if Input.is_action_just_pressed("Space") and is_wall_running:
		wall_jump()
		return
	if Input.is_action_just_pressed("Space"):
		if can_climb and try_wall_climb():
			return
		if is_on_floor():
			Current_jumps = 0
			wall_climb_used = false
			can_jump = true
		if can_jump:
			velocity.y = JUMP_VELOCITY
			Current_jumps += 1
			if Current_jumps == 1 and SkillManager.check_unlocked("double_jump"):
				can_jump = true
			else: can_jump = false

	# Throw weapon if button pressed
	if Input.is_action_just_pressed("throw_weapon"): if not is_paused: throw_weapon()
	# Burst mode if button pressed
	if Input.is_action_just_pressed("burst_mode"): burst_mode()

# ==========================
# MOUSE INPUT
# ==========================
# Moves camera relative to mouse movement
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - event.relative.y * mouse_sensitivity, -tilt_limit, tilt_limit)
		camera_pivot.rotation.y -= event.relative.x * mouse_sensitivity

# ==========================
# PHYSICS PROCESS
# ==========================
# Runs code 60 times per second
func _physics_process(delta: float) -> void:
	# If you can wall run, check the wall, then update the wall run
	if can_wall_run:
		check_wall_run_start()
	if is_wall_running:
		update_wall_run(delta)
	# Handle wall climbing
	handle_wall_climb(delta)
	# If not wall climbing or running, handle movement, dodge, and grapple
	if not is_wall_climbing and not is_wall_running:
		handle_movement(delta)
		handle_dodge(delta)
		handle_grapple(delta)
	# If not wall climbing or running, gravity moves down
	if not is_wall_climbing and not is_wall_running:
		velocity.y += gravity * delta
	# Perform movement
	move_and_slide()
	# If stamina recharge timer is active, lower it according to delta
	if stamina_recharge_timer > 0.0:
		stamina_recharge_timer -= delta
	else:
		current_stamina = min(current_stamina + stamina_recharge_rate * delta, max_stamina)
	# Update stamina bar to reflect current stamina
	if stamina_bar:
		stamina_bar.value = current_stamina
	# If dodge cooldown is active, lower according to delta
	if dodge_cooldown_timer > 0.0:
		dodge_cooldown_timer -= delta
	# If invulnerable, lower timer according to delta, if timer is 0, turn of invincibilty
	if invulnerable:
		invuln_timer -= delta
		if invuln_timer <= 0.0:
			invulnerable = false
	# Handle throw and returning
	if is_weapon_thrown and thrown_weapon:
		if not is_weapon_returning:
			var travel = throw_direction * throw_speed * delta
			thrown_weapon.global_translate(travel)
			thrown_distance += travel.length()
			if thrown_distance >= throw_distance:
				is_weapon_returning = true
				if "disable_damage_window" in thrown_weapon:
					thrown_weapon.disable_damage_window()
		else:
			var target_pos = weapon_holster.global_transform.origin
			thrown_weapon.global_position = thrown_weapon.global_position.lerp(target_pos, return_speed * delta)
			if thrown_weapon.global_position.distance_to(target_pos) < 0.1:
				thrown_weapon.get_parent().remove_child(thrown_weapon)
				weapon_holster.add_child(thrown_weapon)
				thrown_weapon.transform = weapon_original_transform
				thrown_weapon.visible = true
				is_weapon_thrown = false
				is_weapon_returning = false
				thrown_weapon = null
				thrown_distance = 0.0
	if wall_run_lockout:
		wall_run_lockout_timer -= delta
		if wall_run_lockout_timer <= 0.0:
			wall_run_lockout = false


# ==========================
# MOVEMENT
# ==========================
# Controls for moving along ground
func handle_movement(delta: float) -> void:
	# If dodging, grappling, or wall climbing, do nothing
	if is_dodging or is_grappling or is_wall_climbing:
		return
	# If not paused, detect movement direction
	if not is_paused:
		input_vector = Vector2(
			Input.get_action_strength("D") - Input.get_action_strength("A"),
			Input.get_action_strength("W") - Input.get_action_strength("S")
		)
	# Otherwise, do nothing
	else:
		input_vector = Vector2.ZERO
	# Create variable to detect direction
	var move_dir: Vector3 = Vector3.ZERO
	# If there is a direction, then do movement relative to camera
	if input_vector != Vector2.ZERO:
		var cam_basis = camera.global_transform.basis
		var forward = -cam_basis.z; forward.y = 0; forward = forward.normalized()
		var right = cam_basis.x; right.y = 0; right = right.normalized()
		move_dir = (input_vector.x * right + input_vector.y * forward).normalized()
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
		if move_dir.length() > 0.01:
			var target_yaw = atan2(-move_dir.x, -move_dir.z)
			var current_yaw = orientation.rotation.y
			orientation.rotation.y = lerp_angle(current_yaw, target_yaw, delta * 10.0)  # adjust 10.0 for snappiness
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 5)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 5)
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_decay * delta)

# ==========================
# GRAPPLE HANDLING
# ==========================
# Handles the grappling logic
func handle_grapple(delta: float) -> void:
	# If not grappling, do nothing
	if not is_grappling:
		return
	# Stores distance to target as variable
	var to_target = grapple_point - global_transform.origin
	# If distance to target is less than the max length, move towards point
	if to_target.length() > grapple_stop_distance:
		velocity = velocity.lerp(to_target.normalized() * grapple_speed, delta * 8.0)
	# Otherwise, stop grapple
	else:
		cancel_grapple()

# ==========================
# TRYING GRAPPLE
# ==========================
# Attempts to perform grapple
func try_grapple() -> void:
	# If is grappling, cancel grapple
	if is_grappling:
		cancel_grapple(); return
	# If current stamina is less than required, do nothing
	if current_stamina < grapple_stamina_cost:
		return
	# Variables to store for grapple
	var space_state = get_world_3d().direct_space_state
	var ray_origin = camera.global_position
	var ray_end = ray_origin + -camera.global_transform.basis.z * max_grapple_distance
	var query = PhysicsRayQueryParameters3D.new()
	# Tells beginning and end of line
	query.from = ray_origin
	query.to = ray_end
	query.exclude = [self]
	# Stores line as result
	var result = space_state.intersect_ray(query)
	# Tells what grapple point is and sets grappling to true, uses the stamina, and sets the recharge timer
	if result and result.has("position"):
		grapple_point = result["position"]
		is_grappling = true
		current_stamina -= grapple_stamina_cost
		stamina_recharge_timer = stamina_recharge_delay

# ==========================
# CANCEL GRAPPLE
# ==========================
# Cancels grapple when called
func cancel_grapple() -> void: is_grappling = false

# ==========================
# TRYING DODGE
# ==========================
# Handles logic for dodge
func try_dodge() -> void:
	# Sets camera to not clip into player
	$CameraPivot/SpringArm3D.collision_mask = 0
	# If is dodging, grappling, cooldown timer is active, or not enough stamina, then set camera back and do nothing else
	if is_dodging or is_grappling or dodge_cooldown_timer > 0 or current_stamina < dodge_stamina_cost:
		$CameraPivot/SpringArm3D.collision_mask = 1
		return
	# Get dodge direction based on input
	var input_dir = Vector2(
		Input.get_action_strength("D") - Input.get_action_strength("A"),
		Input.get_action_strength("W") - Input.get_action_strength("S")
	)
	# Stores variables for directions based on camera
	var cam_basis = camera.global_transform.basis
	var forward = -cam_basis.z; forward.y = 0
	var right = cam_basis.x; right.y = 0
	# Decides the final direction relative to the camera
	dodge_direction = ( (input_dir.x * right + input_dir.y * forward).normalized() 
						if input_dir.length() > 0.1 else -forward.normalized() )
	is_dodging = true # Sets dodging to true
	dodge_timer = dodge_duration # Sets dodge timer
	dodge_cooldown_timer = dodge_cooldown # Sets dodge cooldown
	current_stamina -= dodge_stamina_cost # Uses current stamina
	stamina_recharge_timer = stamina_recharge_delay # Sets timer for stamina
	# Plays dodge animation
	if anim_player and anim_player.has_animation("dodge_roll"):
		anim_player.play("dodge_roll")
	# Sets invincibilty to true and timer
	invulnerable = true
	invuln_timer = dodge_invincibility_time

# ==========================
# DODGE HANDLING
# ==========================
# Handle starting the dodge
func handle_dodge(delta: float) -> void:
	# If not dodging, do nothing
	if not is_dodging:
		return
	# Sets rotation back to normal
	orientation.rotation.x = 0
	orientation.rotation.z = 0
	# Saves direction as a variable
	var hor_dir = dodge_direction
	# Makes sure you don't move up during dodge
	hor_dir.y = 0
	# Sets velocity of dodge based on speed of dodge
	velocity = hor_dir.normalized() * dodge_speed
	# If length of dodge direction, imma be honest, idk what it does
	if hor_dir.length() > 0.01:
		var target_yaw = atan2(-hor_dir.x, -hor_dir.z)
		orientation.rotation.y = lerp_angle(orientation.rotation.y, target_yaw, delta * 10.0)
	# Lower timer based on delta
	dodge_timer -= delta
	# If dodge timer is 0 or less, set dodging to false and sets camera to normal
	if dodge_timer <= 0.0:
		is_dodging = false
		$CameraPivot/SpringArm3D.collision_mask = 1

# ==========================
# TAKING DAMAGE
# ==========================
# Handles taking damage
func take_damage(amount: int) -> void:
	# If invincible, do nothing
	if invulnerable:
		return
	# Make sure health stays between 0 and max health
	health = clamp(health - amount, 0, max_health)
	# Sets healthbar to reflect current health
	if healthbar: healthbar.value = health
	# If health is zero or less, reload scene
	if health <= 0:
		var current_scene = get_tree().current_scene.name
		if current_scene == "tutorial":
			current_scene = "tutorial.tscn"
		if current_scene == "level 1":
			current_scene = "level_1.tscn"
		elif current_scene == "level 2":
			current_scene = "level_2.tscn"
		elif current_scene == "level_3":
			current_scene = "level_3.tscn"
		SceneManager.change_scene(current_scene)

# ==========================
# HEALING
# ==========================
# Handles healing
func heal(amount: int) -> void:
	# Keeps health between zero and max and adds healing amount
	health = clamp(health + amount, 0, max_health)
	# Sets value of healthbar to current health
	if healthbar: healthbar.value = health

# ==========================
# SWAP WEAPON
# ==========================
# Function to swap weapons
func swap_weapon() -> void:
	# If only one weapon, do nothing
	if weapons.size() <= 1:
		return
	current_weapon.visible = false # Sets current weapon to not visible
	current_weapon_index = (current_weapon_index + 1) % weapons.size() # Increases index by 1
	current_weapon = weapons[current_weapon_index] # Sets new current weapon
	current_weapon.visible = true # Sets new weapon to visible

# ==========================
# UPON COLLECTING COLLECTIBLE
# ==========================
# When collectible collected
func _on_collectible_collected():
	# Increase max health
	max_health += 10
	health += 10
	# Set healthbar to reflect new values
	if healthbar: healthbar.max_value = max_health
	if healthbar: healthbar.value = health
	# Show message that it was collected
	sprite_3d.visible = true
	await get_tree().create_timer(1).timeout
	sprite_3d.visible = false

# ==========================
# PROCESS
# ==========================
# Runs every frame
func _process(delta):
	# If shake amount is active
	if shake_amount > 0.01:
		# Choose random amount to shake
		var offset = Vector3(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount),
			0
		)
		# Shake camera
		camera_pivot.position = offset
		shake_amount = lerp(shake_amount, 0.0, shake_decay * delta)
	else:
		# Reset camera position
		camera_pivot.position = Vector3.ZERO

# ==========================
# ON WEAPON HIT
# ==========================
# When weapon hits, shake camera
func _on_sword_hit(): shake_amount = max(shake_amount, 0.02)
func _on_spear_hit(): shake_amount = max(shake_amount, 0.02)
func _on_dagger_hit(): shake_amount = max(shake_amount, 0.02)

# ==========================
# ON PAUSE MENU BUTTON PRESSED
# ==========================
# When buttons pressed in pause menu
func _on_close_menu_button_down() -> void: # On close menu pressed
	# Set is paused to false
	is_paused = false
	# Hide menu
	v_box.visible = false
	# Capture mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
# On quit to menu, change scene to main menu
func _on_quit_to_menu_button_down() -> void: SceneManager.change_scene("res://main menu.tscn")
# On quit game button, quit game
func _on_quit_button_down() -> void: get_tree().quit()
# On skill tree pressed, change scene to skill tree
func _on_skill_tree_button_down() -> void: SceneManager.change_scene("res://skill_tree.tscn")

# ==========================
# CHECK WALL FOR WALL RUN
# ==========================
# Function to check for wall for wall run
func check_wall_run_start():
	# If is on floor or wall running, do nothing
	if is_on_floor() or is_wall_running or wall_run_lockout:
		return
	# Stores original location, and some other stuff in variables
	var from = global_transform.origin
	var space = get_world_3d().direct_space_state
	var left_dir = -orientation.global_transform.basis.x.normalized()
	# Creates a raycast and sets size
	q.from = from
	q.to = from + left_dir * 1.2
	q.exclude = [self]
	# Result is determined based on if wall is there
	var result = space.intersect_ray(q)
	# If result comes back positive, check if wall is valid
	if result and result.has("position"):
		if is_valid_wall(result["normal"]):
			# If is valid, start run
			start_wall_run(result["normal"])
			return
	# Creates another raycast and sets size
	var right_dir = orientation.global_transform.basis.x.normalized()
	q = PhysicsRayQueryParameters3D.new()
	q.from = from
	q.to = from + right_dir * 1.2
	q.exclude = [self]
	# Checks if raycast hits something
	result = space.intersect_ray(q)
	# If result comes back positive, check if wall is valid
	if result and result.has("position"):
		if is_valid_wall(result["normal"]):
			# If valid, start wall run
			start_wall_run(result["normal"])
			return


# ==========================
# BEGIN WALL RUN
# ==========================
# Function to start wall run
func start_wall_run(wall_normal: Vector3):
	if not is_on_floor():
		# Resets upward velocity
		velocity.y = 0
		# Sets wall running true
		is_wall_running = true
		# Sets timer to zero
		wall_run_timer = 0.0
		# Sets direction of run
		var forward = -orientation.global_transform.basis.z
		forward.y = 0
		wall_run_direction = forward.slide(wall_normal).normalized()
		# Sets velocity
		velocity = wall_run_direction * WALL_RUN_SPEED

# ==========================
# UPDATE WALL RUN
# ==========================
# Update wall run
func update_wall_run(delta):
	wall_run_timer += delta
	# If wall timer is larger than max time, stop wall run
	if wall_run_timer > MAX_WALL_RUN_TIME:
		stop_wall_run()
		return
	# Locks the horizontal movement
	var horizontal = wall_run_direction * WALL_RUN_SPEED
	velocity.x = horizontal.x
	velocity.z = horizontal.z
	# Applies wall run gravity
	velocity.y += WALL_RUN_GRAVITY * delta


# ==========================
# STOP WALL RUN
# ==========================
# Stops wall run when called
func stop_wall_run():
	if not is_wall_running:
		return
	# Sets wall running to false
	is_wall_running = false
	# give a small fall bump
	velocity.y = min(velocity.y, -3.0)
	# ENABLE LOCKOUT
	wall_run_lockout = true
	wall_run_lockout_timer = wall_run_lockout_time


# ==========================
# CHECK WALL FOR CLIMB
# ==========================
# Checks if wall is valid 
func is_valid_wall(normal: Vector3) -> bool:
	# If wall is cieling, return false
	if normal.dot(Vector3.UP) > 0.05:
		return false
	# Declares forward
	var forward = -orientation.global_transform.basis.z
	# Sets forward to not up and down
	forward.y = 0
	forward = forward.normalized()
	# Sets angle of wall
	var angle_metric = abs(forward.dot(normal))
	# Returns result of wall angle < 0.6
	return angle_metric > 0.6

# ==========================
# SAVE CLIMBABLE WALL
# ==========================
# Checks if wall is climbable
func get_climbable_wall() -> Dictionary:
	# Creates new raycast to check for wall in front
	var origin = global_transform.origin + Vector3(0, 1.0, 0)  # chest height
	var space = get_world_3d().direct_space_state
	var dir = -orientation.global_transform.basis.z  # forward
	var query = PhysicsRayQueryParameters3D.new()
	# Sets location of raycast
	query.from = origin
	query.to = origin + dir * 1.5
	query.exclude = [self]
	# Saves wall as variable
	var hit = space.intersect_ray(query)
	# Checks if wall is climable
	if hit and abs(hit.normal.dot(Vector3.UP)) < 0.3:
		return {"hit": true, "normal": hit.normal, "position": hit.position}
	return {"hit": false}

# ==========================
# TRY WALL CLIMB
# ==========================
# Attempt to climb wall
func try_wall_climb() -> bool:
	# If is on floor, is wall climbing, or wall climb was used, do nothing
	if is_on_floor() or is_wall_climbing or wall_climb_used:
		return false
	# Checks if wall is valid to climb
	var info = get_climbable_wall()
	# If not, do nothing
	if not info.hit:
		return false
	# Sets wall climbing to true
	is_wall_climbing = true
	# Sets timer to 0
	wall_climb_timer = 0.0
	# Sets wall to climb to wall
	climb_wall_normal = info.normal
	# Sets velocity to climb wall
	var push_toward_wall = climb_wall_normal * -0.2
	# Moves player and pushes them towards wall
	move_and_collide(push_toward_wall)
	# Sets velocity to up based on climb speed
	velocity.y = WALL_CLIMB_SPEED
	# Sets wall climb to used
	wall_climb_used = true
	return true

# ==========================
# HANDLE WALL CLIMB
# ==========================
# Handle logic for wall climb
func handle_wall_climb(delta: float):
	# If not wall climbing, do nothing
	if not is_wall_climbing:
		return
	# Sets upward velocity to climb speed
	velocity.y = WALL_CLIMB_SPEED
	# Stores push towards wall as variable
	var push_toward_wall = climb_wall_normal * -5 * delta
	# Move player towards wall
	move_and_collide(push_toward_wall)
	# Update timer
	wall_climb_timer += delta
	# If on floor or timer is up, stop climbing
	if wall_climb_timer >= WALL_CLIMB_DURATION or is_on_floor():
		is_wall_climbing = false

# ==========================
# WEAPON THROW
# ==========================
# Function to throw weapon
func throw_weapon():
	# If weapon is thrown or dont have a current weapon, do nothing
	if is_weapon_thrown or not current_weapon:
		return
	# Saves current location as variable
	var weapon_global = current_weapon.global_transform
	# Removes weapon
	weapon_holster.remove_child(current_weapon)
	# Adds weapon back
	get_parent().add_child(current_weapon)
	# Sets global location as original location
	current_weapon.global_transform = weapon_global
	# Sets throw direction
	throw_direction = -camera.global_transform.basis.z.normalized()
	# Sets thrown weapon as current weapon
	thrown_weapon = current_weapon
	# Sets current weapon to invisible
	current_weapon.visible = false
	# Sets weapon as thrown
	is_weapon_thrown = true
	# Sets returning to false
	is_weapon_returning = false
	# Sets thrown distance to 0
	thrown_distance = 0.0
	# Enable damage of weapon
	if "enable_damage_window" in thrown_weapon:
		thrown_weapon.enable_damage_window()

# ==========================
# BURST MODE
# ==========================
# Function to enable burst mode
func burst_mode():
	# Checks if you have it
	if SkillManager.check_unlocked("burst_mode"):
		# Checks if cooldown is active
		if not burst_cooldown:
			# Perform Burst Mode for 10 seconds
			burst_cooldown = true
			red.visible = true
			current_weapon.light_damage += 5
			current_weapon.heavy_damage += 5
			await get_tree().create_timer(10).timeout
			# Disable Burst Mode and start cooldown
			red.visible = false
			current_weapon.light_damage -= 5
			current_weapon.heavy_damage -= 5
			await get_tree().create_timer(10).timeout
			# Set cooldown to inactive
			burst_cooldown = false
			recharged.visible = true
			await get_tree().create_timer(1).timeout
			recharged.visible = false
		else:
			# Tell user it needs to recharge
			needs.visible = true
			await get_tree().create_timer(1).timeout
			needs.visible = false

func wall_jump():
	# stop wall run immediately
	stop_wall_run()
	# Direction: up + away from the wall
	var jump_dir = (last_wall_normal + Vector3.UP).normalized()
	# speed you can tune
	var wall_jump_force := 12.0
	# apply the jump
	velocity = jump_dir * wall_jump_force
	# optional: add horizontal control
	velocity.x += jump_dir.x * 4.0
	velocity.z += jump_dir.z * 4.0
