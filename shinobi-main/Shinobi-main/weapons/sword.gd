extends Node3D

var player: CharacterBody3D = null
var hit_enemies: Array = []
signal hit_landed

# === NODES ===
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var area: Area3D = $hitbox

# === HITPAUSE ===
var hitpause_count = 0
var hitpause_target = 0.05
@export var hit_pause_duration: float = 0.02
var _original_time_scale := 1.0

# === STATS ===
@export var light_damage: int = 7
@export var heavy_damage: int = 10
@export var light_knockback: float = 5.0
@export var heavy_knockback: float = 10.0
@export var stamina_cost_light: float = 7.0
@export var stamina_cost_heavy: float = 10.0
@export var max_combo: int = 3

# === COMBO STATE ===
var can_damage: bool = false
var can_chain: bool = true
var is_attacking: bool = false
var attack_history: Array[String] = []
var rest_transform: Transform3D

# === ANIMATION MAP ===
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
func _ready() -> void:
	Potency.connect("collected", Callable(self, "_on_collected"))
	rest_transform = self.transform
	area.monitoring = false
	area.body_entered.connect(_on_hitbox_body_entered)
	if SkillManager.check_unlocked("pure_sword"):
		light_damage = 12
		heavy_damage = 15
	if SkillManager.check_unlocked("steel_sword"):
		light_damage = 11
		heavy_damage = 14
	if SkillManager.check_unlocked("forged_sword"):
		light_damage = 10
		heavy_damage = 13
	if SkillManager.check_unlocked("sharp_sword"):
		light_damage = 9
		heavy_damage = 12
	if SkillManager.check_unlocked("dull_sword"):
		light_damage = 8
		heavy_damage = 11

# ========================
# ATTACK FUNCTION
# ========================
func attack(is_heavy: bool = false) -> void:
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
	# --- Stamina check ---
	var cost: float = stamina_cost_heavy if is_heavy else stamina_cost_light
	if player.current_stamina < cost:
		return
	player.current_stamina -= cost
	# --- Combo logic ---
	if not can_chain and is_attacking:
		return
	var type_char: String = "H" if is_heavy else "L"
	if not is_attacking:
		is_attacking = true
		attack_history.clear()
	attack_history.append(type_char)
	if attack_history.size() > max_combo:
		attack_history = attack_history.slice(-max_combo, max_combo)
	var sequence: String = "".join(attack_history).strip_edges().to_upper()
	var anim_name: String = combo_map.get(sequence, "") as String
	if anim_name == "":
		anim_name = "swing" if type_char == "L" else "H"
	if anim.has_animation(anim_name):
		anim.play(anim_name)
	can_chain = false

# ========================
# ANIMATION SIGNALS
# ========================
func end_attack() -> void:
	can_damage = false
	area.monitoring = false
	can_chain = true
	hit_enemies.clear()  # reset hit list


func end_combo() -> void:
	attack_history.clear()
	is_attacking = false
	can_chain = true
	can_damage = false
	area.monitoring = false
	hit_enemies.clear()  # reset hit list
	self.transform = rest_transform

# ========================
# PARTICLES + HIT STOP
# ========================
func spawn_hit_particles(hit_position: Vector3, hit_direction: Vector3) -> void:
	var hit_particles_scene: PackedScene = preload("res://hit_particles.tscn")
	var particles: Node3D = hit_particles_scene.instantiate()
	get_tree().current_scene.add_child(particles)

	var offset: Vector3 = hit_direction * 0.2 + Vector3(
		randf_range(-0.1, 0.1),
		randf_range(-0.05, 0.1),
		randf_range(-0.1, 0.1)
	)
	particles.global_position = hit_position + offset
	particles.look_at(hit_position + hit_direction, Vector3.UP)
	particles.emitting = true

	particles.finished.connect(func():
		particles.queue_free()
	)

func hit_pause_global() -> void:
	if hitpause_count == 0:
		# first hitpause, save original scale
		_original_time_scale = Engine.time_scale
		Engine.time_scale = hitpause_target

	hitpause_count += 1
	await get_tree().create_timer(hit_pause_duration).timeout
	hitpause_count -= 1

	if hitpause_count == 0:
		# restore only when last hitpause ends
		Engine.time_scale = _original_time_scale

func set_player(p: Player) -> void:
	player = p

func _on_hitbox_body_entered(body: Node3D) -> void:
	if not can_damage:
		return

	# Find the enemy root
	var enemy_node: Node = body
	while enemy_node and not enemy_node.is_in_group("enemies"):
		enemy_node = enemy_node.get_parent()

	if not enemy_node:
		return

	# --- Prevent multiple hits on same enemy in one swing ---
	if enemy_node in hit_enemies:
		return
	hit_enemies.append(enemy_node)
	
	hit_landed.emit()
	
	# Determine attack type
	var last_type: String = attack_history.back() if attack_history.size() > 0 else "L"
	var atk_damage: int = heavy_damage if last_type == "H" else light_damage
	var atk_knockback: float = heavy_knockback if last_type == "H" else light_knockback
	
	# --- Apply damage ---
	if enemy_node.has_method("take_damage"):
		enemy_node.take_damage(atk_damage)

	# --- Apply knockback ---
	if enemy_node.has_method("apply_knockback"):
		var direction = (enemy_node.global_transform.origin - global_transform.origin).normalized()
		direction.y = 0.01
		enemy_node.apply_knockback(direction * atk_knockback)

	# --- Visuals + hit pause ---
	var hit_pos: Vector3 = body.global_transform.origin
	var hit_dir: Vector3 = (body.global_transform.origin - global_transform.origin).normalized()
	spawn_hit_particles(hit_pos, hit_dir)
	hit_pause_global()

	if body.is_in_group("enemy"):
		get_parent().apply_shake(0.15)

func enable_damage_window() -> void:
	hit_enemies.clear()
	can_damage = true
	area.monitoring = true
	hit_enemies.clear()  # reset hit cache at start of window

func _on_collected():
	self.light_damage += 1
	self.heavy_damage += 1
