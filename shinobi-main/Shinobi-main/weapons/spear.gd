extends Node3D

var player: CharacterBody3D = null
var hit_enemies: Array = []
signal hit_landed

# === NODES ===
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var area: Area3D = $hitbox

# === STATS ===
@export var light_damage: int = 10
@export var heavy_damage: int = 15
@export var light_knockback: float = 5.0
@export var heavy_knockback: float = 10.0
@export var stamina_cost_light: float = 10.0
@export var stamina_cost_heavy: float = 15.0
@export var hit_pause_duration: float = 0.02
@export var max_combo: int = 3

# === COMBO STATE ===
var can_damage: bool = false
var can_chain: bool = true
var is_attacking: bool = false
var attack_history: Array[String] = []
var rest_transform: Transform3D
var is_hit_pausing: bool = false

# === ANIMATION MAP ===
@export var combo_map: Dictionary = {
	"L": "swing",
	"LL": "swing2",
	"LLL": "swing3",
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
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	if SkillManager.check_unlocked("the_ultima_spear"):
		light_damage = 15
		heavy_damage = 20
	if SkillManager.check_unlocked("gilded_spear"):
		light_damage = 14
		heavy_damage = 19
	if SkillManager.check_unlocked("steel_spear"):
		light_damage = 13
		heavy_damage = 18
	if SkillManager.check_unlocked("sharp_spear"):
		light_damage = 12
		heavy_damage = 17
	if SkillManager.check_unlocked("dull_spear"):
		light_damage = 11
		heavy_damage = 16


# ========================
# ATTACK FUNCTION
# ========================
var current_attack_type: String = "L"  # "L" or "H"

func attack(is_heavy: bool = false) -> void:
	if not player:
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			player = players[0]
		else:
			push_warning("Could not find Player in scene!")
			return

	current_attack_type = "H" if is_heavy else "L"

	# --- Stamina check ---
	var cost: float = stamina_cost_heavy if is_heavy else stamina_cost_light
	if player.current_stamina < cost:
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
	var original_time_scale = Engine.time_scale
	Engine.time_scale = 0.05
	await get_tree().create_timer(0.02).timeout
	Engine.time_scale = original_time_scale
	is_hit_pausing = false

func set_player(p: Player) -> void:
	player = p

func _on_hitbox_body_entered(body: Node3D) -> void:
	if not can_damage:
		return
	if body in hit_enemies:
		return
	if body == player:
		return
	hit_enemies.append(body)

	# Apply damage & knockback
	var atk_damage = heavy_damage if current_attack_type == "H" else light_damage
	if body.has_method("take_damage"):
		body.take_damage(atk_damage)

	var atk_knockback = heavy_knockback if current_attack_type == "H" else light_knockback
	if body.has_method("apply_knockback"):
		var direction = (body.global_transform.origin - global_transform.origin).normalized()
		direction.y = 0.1
		body.apply_knockback(direction * atk_knockback)

	# Spawn particles
	spawn_hit_particles(body.global_transform.origin,
		(body.global_transform.origin - global_transform.origin).normalized())
	
	hit_landed.emit()
		
	# Trigger hit pause only once
	if not is_hit_pausing:
		trigger_hit_pause()

func enable_damage_window() -> void:
	hit_enemies.clear()
	can_damage = true
	area.monitoring = true
	# Immediately hit any bodies already in the area
	for body in area.get_overlapping_bodies():
		_on_hitbox_body_entered(body)

func trigger_hit_pause() -> void:
	if is_hit_pausing:
		return
	is_hit_pausing = true
	hit_pause_global()

func _on_collected():
	self.light_damage += 1
	self.heavy_damage += 1
