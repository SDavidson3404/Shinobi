extends CharacterBody3D
class_name Enemy

signal enemy_killed

# ================
# EXPORTED VARS
# ================
@export var gravity: float = -24.8 # Gravity value
@export var attack_cooldown: float = 2.0 # Attack cooldown
@export var speed: float = 5.0 # Speed of movement
@export var attack_range: float = 2.0 # Range where can attack
@export var damage: int = 10 # Damage of enemy
@export var health: int = 70 # Current health
@export var max_health: int = 70 # Max health
@export var knockback_decay: float = 8.0 # Decay of knockback
@export var detection_range: float = 7.5 # How far the enemy can "see" the player
@export var forget_range: float = 15.0 # Stop chasing if player goes beyond this distance

# ================
# NODES
# ================
@onready var anim_player: AnimationPlayer = $AnimationPlayer # Animation player for animations
@onready var sword = $Orientation/Skeleton/EnemySword # Sword of enemy
@onready var orientation = $Orientation # Orientation of the enemy

# =================
# VARIABLES
# =================
var is_alerted: bool = false # Checks if is alerted
var target: Node3D = null # Target to attack
var attack_timer: float = 0.0 # Timer for attacking
var is_attacking: bool = false # Checks if attacking
var knockback_velocity: Vector3 = Vector3.ZERO # Knockback velocity
var anim_token = 0
var anim_task = null
var is_staggered = false

# =================
# READY
# =================
# Runs on load
func _ready():
	# Add enemy to group
	add_to_group("enemies")
	# Get player
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0: target = players[0]
	# If sword has method enable damage, then do it
	if sword and sword.has_method("enable_damage"): sword.damage = damage

# ====================
# PHYSICS PROCESS
# ====================
# Runs 60 frames per second
func _physics_process(delta):
	# If no target, do nothing
	if not target: return
	# If attack timer is larger than 0, lower attack timer
	if attack_timer > 0.0:
		attack_timer -= delta
		# If attack timer is less than 0, set back to zero
		if attack_timer < 0.0: attack_timer = 0.0
	# If not on the floor, apply gravity
	if not is_on_floor(): velocity.y += gravity * delta
	# Otherwise, set gravity to zero
	else: velocity.y = 0.0
	# If knockback velocity is more than 0, set velocity to knockback velocity
	if knockback_velocity.length() > 0.01:
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_decay * delta)
	# Otherwise, do movement
	else: handle_ai_movement(delta)
	# Do movement
	move_and_slide()

# ====================
# HANDLE MOVEMENT
# ====================
# Function to handling movement
func handle_ai_movement(delta):
	# If no target or is attacking, do nothing
	if not target or is_attacking: return
	# Set direction of player
	var to_player = target.global_transform.origin - global_transform.origin
	# Get distance to player
	var distance = to_player.length()
	# If distance is lower than detection range, is alerted is true
	if distance <= detection_range: is_alerted = true
	# Else, if distance is higher than forget range, is alerted is false
	elif distance > forget_range: is_alerted = false
	# If not alerted, set velocity to zero and do nothing
	if not is_alerted:
		velocity.x = 0
		velocity.z = 0
		return
	# If distance is greater than .5:
	if distance > 0.5:
		# Set target rotation
		var target_yaw = atan2(-to_player.x, -to_player.z)
		# Set rotation to target rotation
		orientation.rotation.y = lerp_angle(orientation.rotation.y, target_yaw, delta * 5.0)
	# if distance is less than attack range:
	if distance <= attack_range:
		var target_yaw = atan2(-to_player.x, -to_player.z)
		orientation.rotation.y = lerp_angle(orientation.rotation.y, target_yaw, delta * 5.0)
		# Try attack
		try_attack()
	# Otherwise
	else:
		# Set move direction 
		var move_dir = to_player.normalized()
		# Move towards direction
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed

# ==================
# ATTACK
# ==================
# Function to try an attack
func try_attack():
	# If is attacking or attack timer is active, do nothing
	if is_attacking or attack_timer > 0 or is_staggered:
		return
	# Set is attacking to true
	is_attacking = true
	# Set attack timer to active
	attack_timer = attack_cooldown
	# Play animation
	play_animation("attack")
	# If animation exists:
	if anim_player.has_animation("attack"):
		# Set finished animation as variable
		var finished_anim: String = await anim_player.animation_finished
		# While animation isnt finished, the wait for finished
		while finished_anim != "attack": finished_anim = await anim_player.animation_finished
	# Set attacking to false
	is_attacking = false

# ====================
# PLAY ANIMATION
# ====================
# Function to play animations
func play_animation(anim_name: String):
	# If animation player exists and has animation:
	if anim_player and anim_player.has_animation(anim_name):
		# Stop current animation
		anim_player.stop()
		# Wait one frame
		await get_tree().process_frame
		# Play new animation
		anim_player.play(anim_name)

# ====================
# TAKING DAMAGE
# ====================
# Function to take damage
func take_damage(amount: int) -> void:
	# Lower health by amount
	health -= amount
	if anim_player.has_animation("stagger"):
		is_staggered = true
		anim_player.stop()
		anim_player.play("stagger")
		is_staggered = false
		await get_tree().create_timer(.5).timeout
		anim_player.stop()
	# If health is 0, die
	if health <= 0: die()

# ====================
# DEATH
# ====================
# Runs when enemy killed
func die():
	# Emit enemy killed signal
	enemy_killed.emit()
	# Remove node
	queue_free()
