# Boss.gd
extends CharacterBody3D
class_name Boss

# ========================
# SETTINGS
# ========================
@export var max_health: int = 500
@export var move_speed: float = 4.0
@export var attack_range: float = 5.0
@export var attack_cooldown: float = 2.0

# ========================
# NODES
# ========================
@onready var player: Node3D = get_node("/root/Level_3/Player")
@onready var anim_player: AnimationPlayer = $AnimationPlayer

# ========================
# STATE VARIABLES
# ========================
var health: int
var state: String = "idle"
var attack_timer: float = 0.0

func _ready():
	health = max_health

func _physics_process(delta):
	match state:
		"idle":
			idle_state(delta)
		"attacking":
			attack_state(delta)
		"phase2":
			phase2_state(delta)

# ========================
# STATES
# ========================
func idle_state(_delta):
	look_at_player()
	if is_player_in_range():
		change_state("attacking")

func attack_state(delta):
	attack_timer -= delta
	if attack_timer <= 0:
		perform_attack()
		attack_timer = attack_cooldown
	if health <= 250:
		change_state("phase2")

func phase2_state(delta):
	# Example: faster attacks and moves
	move_toward_player(move_speed * 1.5, delta)
	attack_timer -= delta
	if attack_timer <= 0:
		perform_attack()
		attack_timer = attack_cooldown * 0.7  # faster attacks

# ========================
# ACTIONS
# ========================
func look_at_player():
	var direction = (player.global_transform.origin - global_transform.origin).normalized()
	look_at(global_transform.origin + direction, Vector3.UP)

func is_player_in_range() -> bool:
	return global_transform.origin.distance_to(player.global_transform.origin) <= attack_range

func move_toward_player(speed, _delta):
	var direction = (player.global_transform.origin - global_transform.origin).normalized()
	velocity = direction * speed
	move_and_slide()

func perform_attack():
	# Placeholder for attack logic
	anim_player.play("Attack")
	print("Boss attacks!")  # Replace with actual damage code

func take_damage(amount: int):
	health -= amount
	print("Boss health:", health)
	if health <= 0:
		die()

func die():
	print("Boss defeated!")
	queue_free()

# ========================
# HELPER
# ========================
func change_state(new_state: String):
	state = new_state
	print("Boss changed state to:", state)
