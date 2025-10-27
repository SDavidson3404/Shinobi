extends Node3D
@onready var player: Player = $"../../.."

# === NODES ===
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var area: Area3D = $hitbox
@onready var combo_timer: Timer = $ComboTimer

# === STATS ===
@export var light_damage: int = 10
@export var heavy_damage: int = 20
@export var light_knockback: float = 5.0
@export var heavy_knockback: float = 10.0
@export var stamina_cost_light: float = 10.0
@export var stamina_cost_heavy: float = 20.0
@export var hit_pause_duration: float = 0.07
@export var combo_timeout: float = 1.0
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
	"LHH": "LHH"
}

# ========================
# READY
# ========================
func _ready() -> void:
	rest_transform = self.transform
	area.monitoring = false
	area.body_entered.connect(_on_body_entered)
	combo_timer.timeout.connect(_on_combo_timeout)

# ========================
# PLAYER LOOKUP (Parent Climbing)
# ========================
func find_player() -> Node:
	var node = self
	while node:
		if node.is_class("Player"):
			return node
		node = node.get_parent()
	return null

# ========================
# ATTACK FUNCTION
# ========================
func attack(is_heavy: bool = false) -> void:
	if not player:
		push_warning("Could not find Player in parent hierarchy!")
		return

	# --- Stamina check ---
	var cost: float = stamina_cost_heavy if is_heavy else stamina_cost_light
	if player.current_stamina < cost:
		print("Not enough stamina!")
		return

	player.current_stamina -= cost
	player.stamina_recharge_timer = player.stamina_recharge_delay

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
	else:
		push_warning("Missing animation: %s (sequence: %s)" % [anim_name, sequence])

	can_damage = true
	area.monitoring = true
	can_chain = false
	combo_timer.start(combo_timeout)

# ========================
# ANIMATION SIGNALS
# ========================
func enable_next_chain() -> void:
	can_chain = true

func end_attack() -> void:
	can_damage = false
	area.monitoring = false
	can_chain = true

func end_combo() -> void:
	attack_history.clear()
	is_attacking = false
	can_chain = true
	can_damage = false
	area.monitoring = false
	self.transform = rest_transform

func _on_combo_timeout() -> void:
	end_combo()

# ========================
# HIT DETECTION
# ========================
func _on_body_entered(body: Node) -> void:
	if not can_damage:
		return

	var enemy_node: Node = body
	if not enemy_node.is_in_group("enemies") and body.get_parent() != null:
		enemy_node = body.get_parent()

	if not enemy_node.is_in_group("enemies"):
		return

	var last_type: String = attack_history.back() if attack_history.size() > 0 else "L"
	var atk_damage: int = heavy_damage if last_type == "H" else light_damage
	var atk_knockback: float = heavy_knockback if last_type == "H" else light_knockback

	var direction: Vector3 = (enemy_node.global_transform.origin - global_transform.origin).normalized()
	direction.y = 0.01

	spawn_hit_particles(enemy_node.global_position, direction)

	if enemy_node.has_method("apply_knockback"):
		enemy_node.apply_knockback(direction * atk_knockback)

	if enemy_node.has_method("take_damage"):
		enemy_node.take_damage(atk_damage)

	hit_pause_global()

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
	Engine.time_scale = 0.0
	var start_time: int = Time.get_ticks_msec()
	var duration_ms: int = int(hit_pause_duration * 1000)
	while Time.get_ticks_msec() - start_time < duration_ms:
		OS.delay_msec(1)
	Engine.time_scale = 1.0
