extends Node3D

var player: CharacterBody3D = null # Player as variable
var hit_enemies: Array = [] # Array for enemies previously hit
signal hit_landed # Signal that hit landed

# === NODES ===
@onready var anim: AnimationPlayer = $AnimationPlayer # Animations for sword
@onready var area: Area3D = $hitbox # Hitbox of sword
@onready var buster_sword: Node3D = $"buster sword" # Sword Tier 3
@onready var sharp_sword: Node3D = $"Sharp sword" # Sword Tier 2
@onready var base_sword: MeshInstance3D = $"Base Sword" # Sword Tier 1

# === HITPAUSE ===
var hitpause_count = 0 # Amount of hitpauses
var hitpause_target = 0.05 # The target speed of the engine during hitpause
@export var hit_pause_duration: float = 0.02 # Length of hitpause
var _original_time_scale := 1.0 # Original speed of engine

# === STATS ===
@export var light_damage: int = 7 # Original Light attack damage
@export var heavy_damage: int = 10 # Original Heavy attack damage
@export var light_knockback: float = 5.0 # Knockback of light attack
@export var heavy_knockback: float = 10.0 # Knockback of heavy attack
@export var stamina_cost_light: float = 7.0 # Light attack stamina cost
@export var stamina_cost_heavy: float = 10.0 # Heavy attack stamina cost
@export var max_combo: int = 3 # Max amount of hits per combo

# === COMBO STATE ===
var can_damage: bool = false # Checks if you can damage
var can_chain: bool = true # Checks if you can chain attacks
var is_attacking: bool = false # Checks if currently attacking
var attack_history: Array[String] = [] # Array to store current chain
var rest_transform: Transform3D # Variable to store the resting position

# === ANIMATION MAP ===
# Animations and their corresponding combo map
@export var combo_map: Dictionary = {
	"L": "swing",
	"LL": "swing_2",
	"LLL": "swing_3",
	"H": "H1",
	"HH": "HH",
	"HL": "HL",
	"LH": "LH",
	"LHL": "LHL",
	"HLH": "HLH",
	"HHL": "HHL",
	"LHH": "LHH",
	"HLL": "HLL",
	"LLH": "LLH",
	"HHH": "HHH"
}

# ========================
# READY
# ========================
# Runs when scene is loaded
func _ready() -> void:
	# Add sword to "player_attack" group
	add_to_group("player_attack")
	# Set resting location of weapon
	rest_transform = self.transform
	# Set hitbox monitoring to false
	area.monitoring = false
	# Connect to body entering hitbox
	area.body_entered.connect(_on_hitbox_body_entered)
	# Checks if you have weapon upgrades and sets damage
	update_damage()

# ========================
# ATTACK FUNCTION
# ========================
# Function to attack
func attack(is_heavy: bool = false) -> void:
	# If player is not valid
	if not player:
		# Set player to node in "player" group
		var players = get_tree().get_nodes_in_group("player")
		# If player size is larger than zero, then player is first in group
		if players.size() > 0: player = players[0]
	# Save attack cost depending on if you use heavy or light
	var cost: float = stamina_cost_heavy if is_heavy else stamina_cost_light
	# If current stamina is less than what it costs, do nothing
	if player.current_stamina < cost: return
	# Reduce current stamina by cost
	player.current_stamina -= cost
	# If you cannot chain or are attacking, do nothing
	if not can_chain and is_attacking: return
	# Save attack type as character in attack map.
	var type_char: String = "H" if is_heavy else "L"
	# If not attacking, then set attacking to true and reset attack history
	if not is_attacking:
		is_attacking = true
		attack_history.clear()
	# Append the attack history with the character of H or L
	attack_history.append(type_char)
	# If more than 4 attacks, slice the combo
	if attack_history.size() > max_combo: attack_history = attack_history.slice(-max_combo, max_combo)
	# Save sequence of attacks as string
	var sequence: String = "".join(attack_history).strip_edges().to_upper()
	# Save animation name as string
	var anim_name: String = combo_map.get(sequence, "") as String
	# If animation name is blank, play the first animation for heavy or light
	if anim_name == "": anim_name = "swing" if type_char == "L" else "H"
	# If animation exists, play it
	if anim.has_animation(anim_name): anim.play(anim_name)
	# Set can chain to false
	can_chain = false

# ========================
# END ATTACK
# ========================
# Function to end attack and allow the next attack
func end_attack() -> void:
	can_damage = false # Set damaging to false
	area.monitoring = false # Set monitoring to false
	can_chain = true # Set can chain to true
	hit_enemies.clear()  # clear list of hit enemies

# ========================
# END COMBO
# ========================
# Function to end the combo
func end_combo() -> void:
	attack_history.clear() # Clear attack history
	is_attacking = false # Set is attacking to false
	can_chain = true # Set chain to true
	can_damage = false # Set damage to false
	area.monitoring = false # Set monitoring to false
	hit_enemies.clear()  # clear list of hit enemies
	self.transform = rest_transform # Reset location of weapon

# ========================
# PARTICLES + HIT STOP
# ========================
# Spawn the particles
func spawn_hit_particles(hit_position: Vector3, hit_direction: Vector3) -> void:
	# Save scene as variable
	var hit_particles_scene: PackedScene = preload("res://hit_particles.tscn")
	# Save instance of scene as variable
	var particles: Node3D = hit_particles_scene.instantiate()
	# Add instance of scene
	get_tree().current_scene.add_child(particles)
	# Set offset of particles
	var offset: Vector3 = hit_direction * 0.2 + Vector3(
		randf_range(-0.1, 0.1),
		randf_range(-0.05, 0.1),
		randf_range(-0.1, 0.1)
	)
	# Set global position of particles
	particles.global_position = hit_position + offset
	# Points the particles in the correct direction
	particles.look_at(hit_position + hit_direction, Vector3.UP)
	# Emit particles
	particles.emitting = true
	# Delete particles when finished
	particles.finished.connect(func(): particles.queue_free())

# ========================
# PARTICLES + HIT STOP
# ========================
# Function to activate hitpause
func hit_pause_global() -> void:
	# If you havent hitpaused yet:
	if hitpause_count == 0:
		# Save original timescale
		_original_time_scale = Engine.time_scale
		# Set timescale to target
		Engine.time_scale = hitpause_target
	# Increase hitpause count
	hitpause_count += 1
	# Create timer based on duration and wait for timeout
	await get_tree().create_timer(hit_pause_duration).timeout
	# Reset hitpause count
	hitpause_count -= 1
	# If hitpause is 0, restore timescale
	if hitpause_count == 0: Engine.time_scale = _original_time_scale

# ========================
# SET PLAYER
# ========================
# Function to set the player
func set_player(p: Player) -> void: player = p

# ========================
# ON BODY ENTERED
# ========================
# Runs when body enters hitbox
func _on_hitbox_body_entered(body: Node3D) -> void:
	# If you cannot damage, do nothing
	if not can_damage: return
	# Set enemy to the body that entered
	var enemy_node: Node = body
	# While enemy is not in group "enemies", get parent
	while enemy_node and not enemy_node.is_in_group("enemies"): enemy_node = enemy_node.get_parent()
	# If enemy isnt valid, do nothing
	if not enemy_node: return
	# If enemy is in hit enemies, do nothing
	if enemy_node in hit_enemies: return
	# Add hit enemy to hit enemies
	hit_enemies.append(enemy_node)
	# Emit hit landed signal
	hit_landed.emit()
	# Saves last attack type
	var last_type: String = attack_history.back() if attack_history.size() > 0 else "L"
	# Saves attack damage
	var atk_damage: int = heavy_damage if last_type == "H" else light_damage
	# If enemy has "take_damage", do it.
	if enemy_node.has_method("take_damage"): enemy_node.take_damage(atk_damage)
	# Gets hit location
	var hit_pos: Vector3 = body.global_transform.origin
	# Gets hit direction
	var hit_dir: Vector3 = (body.global_transform.origin - global_transform.origin).normalized()
	# Spawn hit particles relative to direction and position
	spawn_hit_particles(hit_pos, hit_dir)
	# Run the hit pause
	hit_pause_global()
	# If enemy is in group "enemy", get parent and apply shake
	if body.is_in_group("enemy"): get_parent().apply_shake(0.15)

# ========================
# ENABLE DAMAGE
# ========================
# Function to enable damage
func enable_damage_window() -> void:
	hit_enemies.clear() # Clear hit enemies
	can_damage = true # Set damage to true
	area.monitoring = true # Set monitoring to true

func update_model():
	var swords = {
		"buster_sword": buster_sword,
		"sharp_sword": sharp_sword,
		"base_sword": base_sword
	}
	# Default: base sword
	var active = "base_sword"
	# Find first unlocked sword in priority order
	for sword_name in ["buster_sword", "sharp_sword"]:
		if SkillManager.check_unlocked(sword_name):
			active = sword_name
			break
	# Toggle visibility
	for title in swords:
		swords[title].visible = (title == active)

func update_damage():
	if SkillManager.check_unlocked("buster_sword"):
		light_damage = 12
		heavy_damage = 15
	elif SkillManager.check_unlocked("sharp_sword"):
		light_damage = 9
		heavy_damage = 12
