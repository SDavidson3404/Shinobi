# Boss.gd
extends CharacterBody3D
class_name Boss
signal died

# ========================
# SETTINGS
# ========================
@export var max_health: int = 500 # Max health
@export var move_speed: float = 4.0 # Speed of movement
@export var attack_range: float = 5.0 # Range at which boss can attack
@export var attack_cooldown: float = 2.0 # Cooldown between attacks
@export var recover_amount: int = 100 # Amount healed when recovering
@export var recover_time: float = 2.5 # recovery time
@export var can_recover_below_hp: int = 250 # Can recover below this health
@export var damage: int = 20 # Amount of damage


# ========================
# NODES
# ========================
@onready var player: Player = null # Player as variable
@onready var anim_player: AnimationPlayer = $AnimationPlayer # Animation player for animations
@onready var healthbar: ProgressBar = $"../Healthbar" # Healthbar

# ========================
# STATE VARIABLES
# ========================
var health: int # Current health
var state: String = "idle" # Current state
var attack_timer: float = 0.0 # Timer for attack
var GRAVITY = -24.8 # Gravity factor
var recover_timer = 0.0 # Timer for recovery
var has_healed = false # Checks if healed
var hit_enemies = [] # Keeps hit enemies per swing

# ========================
# READY
# ========================
# Runs when scene loads
func _ready():
	health = max_health # Sets health to max health
	add_to_group("enemies") # Adds boss to group "enemies"

# ========================
# PHYSICS PROCESS
# ========================
# Runs 60 fps
func _physics_process(delta):
	if healthbar: healthbar.value = health # Set healthbar value to health
	# If not on floor:
	if not is_on_floor():
		# Apply gravity
		velocity.y += GRAVITY * delta
		# Apply movement
		move_and_slide()
	# Check state and do action accordingly
	match state:
		"idle":
			idle_state(delta)
		"attacking":
			attack_state(delta)
		"phase2":
			phase2_state(delta)
		"recover":
			recover_state(delta)


# ========================
# IDLE STATE
# ========================
# Runs during Idle
func idle_state(delta):
	look_at_player() # Look at the player
	# Move towards the player
	move_toward_player(move_speed, delta)
	# If player is within range:
	if is_player_in_range():
		# Change to attacking state
		change_state("attacking")

# ========================
# ATTACK STATE
# ========================
# Runs while attack state is active
func attack_state(delta):
	# Look at the player
	look_at_player()
	# Lower attack timer
	attack_timer -= delta
	# If player is not within range:
	if not is_player_in_range():
		# Change state to idle
		change_state("idle")
	# If attack timer is out:
	if attack_timer <= 0:
		# Perform attack
		perform_attack()
		# Reset attack timer
		attack_timer = attack_cooldown
	# If health is greater than recover health, do nothing
	if health <= can_recover_below_hp:
			return
	# If health is lower than half, change state to recover
	if health <= 250:
		change_state("recover")

# ========================
# PHASE 2 STATE
# ========================
# Runs within phase 2
func phase2_state(delta):
	# If player is not within range
	if not is_player_in_range():
		# move towards player
		move_toward_player(move_speed * 1.5, delta)
	# Lower attack timer
	attack_timer -= delta
	# If attack timer is out
	if attack_timer <= 0:
		# Perform attack
		perform_attack()
		# Set lower attack timer
		attack_timer = attack_cooldown * 0.7  # faster attacks

# ========================
# LOOK AT PLAYER
# ========================
# Function to look at player
func look_at_player():
	# Get player
	var p = get_player()
	if p == null:
		return
	# Set direction relative to player
	var direction = (p.global_transform.origin - global_transform.origin).normalized()
	# Set y aspect to 0
	direction.y = 0
	# Turn towards direction
	look_at(global_transform.origin + direction, Vector3.UP)

# ========================
# PLAYER IN RANGE CHECK
# ========================
# Checks if player is in range
func is_player_in_range() -> bool:
	# Get player
	var p = get_player()
	if p == null:
		return false
	# Return result of if within range
	return global_transform.origin.distance_to(p.global_transform.origin) <= attack_range

# ========================
# MOVE TOWARDS PLAYER
# ========================
# Moves towards player when called
func move_toward_player(speed, _delta):
	# Get player
	var p = get_player()
	if p == null:
		return
	# Get direction relative to player
	var direction = (p.global_transform.origin - global_transform.origin).normalized()
	# Set x and z, leaving y zero
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	# Perform movement
	move_and_slide()

# ========================
# PERFORM ATTACK
# ========================
# Does attack when called
func perform_attack():
	# Play animation
	anim_player.play("Attack")
	# Create timer and wait for timeout
	await get_tree().create_timer(1).timeout
	# Clear hit enemies
	hit_enemies.clear()

# ========================
# TAKE DAMAGE
# ========================
# Function to take damage
func take_damage(amount: int):
	# Lower health relative to damage
	health -= amount
	# If health is zero
	if health <= 0:
		# Die
		die()

# ========================
# DIE
# ========================
# Runs to kill boss
func die(): 
	queue_free() # Delete the node
	LevelManager.levels_completed["level_3"] = true
	LevelManager.save_skills()
	SkillManager.player_points += 3
	SkillManager.save_skills()
	died.emit()

# ========================
# CHANGE STATE
# ========================
# Function to change the state
func change_state(new_state: String): state = new_state # Set state to new state

# ========================
# GET PLAYER
# ========================
# Function to get player
func get_player():
	# If player is set to null or not valid:
	if player == null or not is_instance_valid(player):
		# Set player to player
		player = get_tree().get_first_node_in_group("player")
	# Return the result
	return player

# ========================
# RECOVER STATE
# ========================
# State of recovery
func recover_state(delta):
	# Set velocity to zero
	velocity = Vector3.ZERO
	# Get player
	get_player()
	# If recovery timer is zero
	if recover_timer == 0:
		# Play animation if they have it
		if anim_player.has_animation("Recover"):
			anim_player.play("Recover")
		# Set healed to false
		has_healed = false
	# Add recovery timer
	recover_timer += delta
	# if recovery timer is more than half of max time and has not healed:
	if recover_timer >= recover_time * 0.5 and not has_healed:
		# Clamp the health to max health and 0 after adding
		health = clamp(health + recover_amount, 0, max_health)
		# Set has healed to true
		has_healed = true
	# If recovery timer is more than the max time:
	if recover_timer >= recover_time:
		# Set recovery timer to 0
		recover_timer = 0.0
		# Play animation
		anim_player.play("Phase_Transition")
		# Change state to phase 2
		change_state("phase2")

# ========================
# ON BODY ENTERED
# ========================
# Runs when body hits hitbox
func _on_enemy_sword_body_entered(body: Node3D) -> void:
	# If body is in hit_enemies, do nothing
	if body in hit_enemies:
		return
	# If body is in player group
	if body.is_in_group("player"):
		# Append bobdy to hit enemies
		hit_enemies.append(body)
		# If body has method take damage, do it
		if body.has_method("take_damage"):
			body.take_damage(damage)
