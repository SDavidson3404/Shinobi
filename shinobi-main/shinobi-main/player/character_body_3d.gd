extends CharacterBody3D
class_name Player

# ========================
# NODES
# ========================
# Parts of the scene
@onready var orientation: Node3D = $Orientation # Orientation of everything but camera
@onready var anim_player: AnimationPlayer = $Orientation/aspects/AnimationPlayer # Animations of player
@onready var camera_pivot: Node3D = $CameraPivot # Parent of camera aspects
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D # Camera
@onready var weapon_holster: Node3D = $"Orientation/aspects/Weapon holster" # Holster for all weapons
@onready var sword: Node3D = $"Orientation/aspects/Weapon holster/Sword" # Player's sword
@onready var spear: Node3D = $"Orientation/aspects/Weapon holster/Spear" # Player's spear
@onready var v_box: VBoxContainer = $CameraPivot/VBoxContainer # Pause Menu
@onready var dagger: Node3D = $"Orientation/aspects/Weapon holster/Dagger" # Player's dagger
@onready var springarm: SpringArm3D = $CameraPivot/SpringArm3D # Springarm for camera
@onready var healthbar: ProgressBar = $UI/Healthbar # Health bar
@onready var stamina_bar: ProgressBar = $UI/StaminaBar # Stamina bar
@onready var needs: Label = $UI/needs # Label to denote burst mode needs to recharge
@onready var recharged: Label = $UI/Recharged # Label to denote burst mode is recharged
@onready var red: Sprite2D = $UI/red # Red screen for burst mode
@onready var skill_tree: Node2D = $"CameraPivot/Skill Tree" # The Skill Tree
@onready var ui: CanvasLayer = $UI # The UI that is usually on screen

# ==========================
# STATS
# ==========================
# Variables related to stats
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
# Variables related to mouse controls
@export_range(0.0, 0.1) var mouse_sensitivity: float = 0.01 # Mouse sensitivity
@export var tilt_limit: float = deg_to_rad(75) # Camera limit

# ==========================
# WEAPON
# ==========================
# Variables related to weapons
var weapons: Array[Node3D] = [] # Array of weapons
var current_weapon_index: int = 0 # Current weapon's index
var current_weapon: Node3D = null # Current weapon's node

# ==========================
# JUMP
# ==========================
# Variables related to jumping
var gravity := -18.8 # Gravity strength
var Current_jumps = 0 # Number of jumps performed
var can_jump := false # Checks if can jump

# ==========================
# WALL RUN + CLIMB
# ==========================
# Variables related to wall running and climbing
@export var WALL_CLIMB_DURATION: float = 1.0 # How long you can climb
@export var WALL_CLIMB_SPEED: float = 10.0 # Speed at which you climb
const MAX_WALL_RUN_TIME := 3.0 # Max time to wall run
const WALL_RUN_SPEED := 9.0 # Wall run speed
const WALL_RUN_GRAVITY := -5.0 # Gravity during wall run
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
# Variables relating to dodge
@export var dodge_speed: float = 35.0 # Speed of movement during dodge
@export var dodge_duration: float = 0.25 # Duration of movement during dodge
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
# COMBAT EFFECTS
# ==========================
var knockback_velocity: Vector3 = Vector3.ZERO # Velocity of knockback
var knockback_decay: float = 10.0 # Decay of knockback over time
var shake_amount: float = 0.0 # Amount shaken
var shake_decay: float = 5.0 # Shake decay

# ==========================
# ETC
# ==========================
var skill_tree_visible = false # checks if skill tree is visible
var is_paused = false # Checks if paused
var burst_cooldown := false # Checks if cooldown is active on burst

# ========================
# READY
# ========================
# Performs as scene is loaded
func _ready() -> void:
	# Connect signals to functions
	sword.connect("hit_landed", Callable(self, "_on_hit"))
	spear.connect("hit_landed", Callable(self, "_on_hit"))
	dagger.connect("hit_landed", Callable(self, "_on_hit"))
	# Captures mouse
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Adds player to group "player"
	add_to_group("player")
	set_up_weapons()
	check_unlocks()

# ==========================
# INPUT
# ==========================
# Actions when buttons pressed
func _input(event):
	# If escape is pressed
	if event.is_action_pressed("ESCAPE"):
		if skill_tree_visible:
			skill_tree.visible = false
			ui.visible = true
			v_box.visible = true
		if not is_paused: # If not paused
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE # Set Mouse to Visible
			v_box.visible = true # Set Pause Menu to Visible
			is_paused = true # Set is paused to True
		elif is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED # Capture Mouse
			v_box.visible = false # Set pause menu to not visible
			is_paused = false # Set is paused to false
			weapons.clear()
			set_up_weapons()
			check_unlocks() # Checks what unlocks you have
			current_weapon.update_damage()
	# If clicking on window while mouse is not captured and game is not paused, capture mouse
	if event.is_action_pressed("click") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if not is_paused: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	# Swap Weapon if button is pressed
	if event.is_action_pressed("Weapon Swap"): if not is_paused: swap_weapon()
	# If clicking, light_attack
	if Input.is_action_just_pressed("click") and current_weapon and not is_paused: current_weapon.attack(false)
	# If right_click, heavy attack
	if Input.is_action_just_pressed("heavy_attack") and current_weapon and not is_paused: current_weapon.attack(true)
	# If press dodge and dodge unlocked, dodge
	if Input.is_action_pressed("dodge"): if SkillManager.check_unlocked("dodge"):
			if not is_paused: try_dodge()
	# If space pressed
	if Input.is_action_just_pressed("Space"):
		if is_wall_running:
			stop_wall_run()
			velocity.y = JUMP_VELOCITY
		# If can climb, try wall climb, do nothing else
		if can_climb and try_wall_climb(): return
		# If on floor
		if is_on_floor():
			# Set current jumps to 0
			Current_jumps = 0
			# Reset wall climb
			wall_climb_used = false
			# Reset jump
			can_jump = true
		# If can jump
		if can_jump:
			# Set upward velocity
			velocity.y = JUMP_VELOCITY
			# Increase current jumps
			Current_jumps += 1
			# If current jumps is 1 and double jump unlocked, can jump is true
			if Current_jumps == 1 and SkillManager.check_unlocked("double_jump"): can_jump = true
			# Otherwise can jump is false
			else: can_jump = false
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
	if can_wall_run and not is_on_floor(): check_wall_run_start()
	# If wall running, update the wall run
	if is_wall_running: update_wall_run(delta)
	# Handle wall climbing
	handle_wall_climb(delta)
	# If not wall climbing or running, handle movement, dodge
	if not is_wall_climbing and not is_wall_running:
		handle_movement(delta)
		handle_dodge(delta)
	# If not wall climbing or running, gravity moves down
	if not is_wall_climbing and not is_wall_running: velocity.y += gravity * delta
	# Perform movement
	move_and_slide()
	# If stamina recharge timer is active, lower it according to delta
	if stamina_recharge_timer > 0.0: stamina_recharge_timer -= delta
	# Otherwise, add to stamina
	else: current_stamina = min(current_stamina + stamina_recharge_rate * delta, max_stamina)
	# Update stamina bar to reflect current stamina
	if stamina_bar: stamina_bar.value = current_stamina
	# If dodge cooldown is active, lower according to delta
	if dodge_cooldown_timer > 0.0: dodge_cooldown_timer -= delta
	# If invulnerable, lower timer according to delta, if timer is 0, turn of invincibilty
	if invulnerable:
		invuln_timer -= delta
		if invuln_timer <= 0.0: invulnerable = false
	# If wall run is locked, lower timer
	if wall_run_lockout:
		wall_run_lockout_timer -= delta
		# If timer is 0 or less, set lockout to false
		if wall_run_lockout_timer <= 0.0: wall_run_lockout = false


# ==========================
# MOVEMENT
# ==========================
# Controls for moving along ground
func handle_movement(delta: float) -> void:
	# If dodging or wall climbing, do nothing
	if is_dodging or is_wall_climbing: return
	# If not paused, detect movement direction
	if not is_paused:
		input_vector = Vector2(
			Input.get_action_strength("D") - Input.get_action_strength("A"),
			Input.get_action_strength("W") - Input.get_action_strength("S")
		)
	# Otherwise, do nothing
	else: input_vector = Vector2.ZERO
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
# TRYING DODGE
# ==========================
# Handles logic for dodge
func try_dodge() -> void:
	# If is dodging, cooldown timer is active, or not enough stamina, then set camera back and do nothing else
	if is_dodging or dodge_cooldown_timer > 0: return
	if current_stamina < dodge_stamina_cost:return
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
	if anim_player and anim_player.has_animation("dodge_roll"): anim_player.play("dodge_roll")
	# Sets invincibilty to true
	invulnerable = true
	# Sets invulerability timer
	invuln_timer = dodge_invincibility_time

# ==========================
# DODGE HANDLING
# ==========================
# Handle starting the dodge
func handle_dodge(delta: float) -> void:
	# If not dodging, do nothing
	if not is_dodging:return
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
		await get_tree().create_timer(0.1).timeout
		springarm.spring_length = 3.0  # Restore springarm length to normal
		springarm.collision_mask = 1 # Set collision mask back

# ==========================
# TAKING DAMAGE
# ==========================
# Handles taking damage
func take_damage(amount: int) -> void:
	# If invincible, do nothing
	if invulnerable: return
	# Make sure health stays between 0 and max health
	health = clamp(health - amount, 0, max_health)
	# Sets healthbar to reflect current health
	if healthbar: healthbar.value = health
	# If health is zero or less, reload scene
	if health <= 0: die()

func die():
	var current_scene = get_tree().current_scene.name
	if current_scene == "Level": current_scene = "level"
	await get_tree().create_timer(1).timeout
	SceneManager.change_scene(current_scene + ".tscn")

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
	if weapons.size() <= 1: return
	current_weapon.visible = false # Sets current weapon to not visible
	current_weapon_index = (current_weapon_index + 1) % weapons.size() # Increases index by 1
	current_weapon = weapons[current_weapon_index] # Sets new current weapon
	current_weapon.visible = true # Sets new weapon to visible
	current_weapon.update_model() # Updates the new weapon's model

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
	# Otherwise, reset position
	else: camera_pivot.position = Vector3.ZERO

# ==========================
# ON WEAPON HIT
# ==========================
# When weapon hits, shake camera
func _on_hit(): shake_amount = max(shake_amount, 0.02)

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
	# Clear weapons
	weapons.clear()
	# set up weapons
	set_up_weapons()
	# Check if can wall run or climb
	check_unlocks()
	current_weapon.update_damage()
# On quit to menu, change scene to main menu
func _on_quit_to_menu_button_down() -> void: SceneManager.change_scene("res://main menu.tscn")
# On quit game button, quit game
func _on_quit_button_down() -> void: get_tree().quit()
# On skill tree pressed
func _on_skill_tree_button_down() -> void:
	skill_tree_visible = true
	# Set ui visibility to false 
	ui.visible = false
	# Set menu visibilty to false
	v_box.visible = false
	# Set skill tree visibility to true
	skill_tree.visible = true
	# Update Buttons
	Skills.update_visual()

# ==========================
# CHECK WALL FOR WALL RUN
# ==========================
# Function to check for wall for wall run
func check_wall_run_start():
	# If is on floor or wall running, do nothing
	if is_on_floor() or is_wall_running or wall_run_lockout: return
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
	if not is_wall_running: return
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
	if normal.dot(Vector3.UP) > 0.05: return false
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
	if hit and abs(hit.normal.dot(Vector3.UP)) < 0.3: return {"hit": true, "normal": hit.normal, "position": hit.position}
	return {"hit": false}

# ==========================
# TRY WALL CLIMB
# ==========================
# Attempt to climb wall
func try_wall_climb() -> bool:
	# If is on floor, is wall climbing, or wall climb was used, do nothing
	if is_on_floor() or is_wall_climbing or wall_climb_used: return false
	# Checks if wall is valid to climb
	var info = get_climbable_wall()
	# If not, do nothing
	if not info["hit"]: return false
	# Sets wall climbing to true
	is_wall_climbing = true
	# Sets timer to 0
	wall_climb_timer = 0.0
	# Sets wall to climb to wall
	climb_wall_normal = info.normal
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
	if not is_wall_climbing: return
	# Sets upward velocity to climb speed
	velocity.y = WALL_CLIMB_SPEED
	# Update timer
	wall_climb_timer += delta
	# If on floor or timer is up, stop climbing
	if wall_climb_timer >= WALL_CLIMB_DURATION or is_on_floor(): is_wall_climbing = false

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
			sword.light_damage += 5
			sword.heavy_damage += 5
			dagger.light_damage += 5
			dagger.heavy_damage += 5
			spear.light_damage += 5
			spear.heavy_damage += 5
			await get_tree().create_timer(10).timeout
			# Disable Burst Mode and start cooldown
			red.visible = false
			sword.light_damage -= 5
			sword.heavy_damage -= 5
			spear.light_damage -= 5
			spear.heavy_damage -= 5
			dagger.light_damage -= 5
			dagger.heavy_damage -= 5
			burst_cooldown = true
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

# ==========================
# BACK TO GAME
# ==========================
# Function to close skill tree
func _on_back_to_game_button_down() -> void:
	skill_tree_visible = false
	# Set ui to visible
	ui.visible = true
	# Set skill tree to not visible
	skill_tree.visible = false
	# Set menu to visible
	v_box.visible = true

func set_up_weapons():
	for child in weapon_holster.get_children():
		# If child is a node
		if child is Node3D:
			# If child is named "sword", append sword
			if child.name == "Sword": weapons.append(child)
			# Otherwise if child named "spear" and unlocked, append weapon
			if child.name == "Spear": if SkillManager.check_unlocked("spear_unlock"): weapons.append(child)
			# Otherwise if child named "dagger" and unlocked, append weapon
			if child.name == "Dagger": if SkillManager.check_unlocked("dagger_unlock"): weapons.append(child)
			# Set child to not visible
			child.visible = false
	# Sets current weapon to first weapon
	if weapons.size() > 0:
		current_weapon_index = 0
		current_weapon = weapons[current_weapon_index]
		current_weapon.visible = true

func check_unlocks():
	# Checks if wall run or climb is available
	can_wall_run = SkillManager.check_unlocked("wall_run")
	can_climb = SkillManager.check_unlocked("wall_scramble")
	# Set max health based on unlocks
	if SkillManager.check_unlocked("health5"): max_health = 175
	elif SkillManager.check_unlocked("health4"): max_health = 150
	elif SkillManager.check_unlocked("health3"): max_health = 130
	elif SkillManager.check_unlocked("health2"): max_health = 115
	elif SkillManager.check_unlocked("health1"): max_health = 105
	# Set max stamina based on unlocks
	if SkillManager.check_unlocked("stamina5"): max_stamina = 175
	elif SkillManager.check_unlocked("stamina4"): max_stamina = 150
	elif SkillManager.check_unlocked("stamina3"): max_stamina = 130
	elif SkillManager.check_unlocked("stamina2"): max_stamina = 115
	elif SkillManager.check_unlocked("stamina1"): max_stamina = 105
	# Update the Model
	current_weapon.update_model()
