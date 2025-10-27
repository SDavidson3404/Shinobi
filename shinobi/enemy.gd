extends CharacterBody3D

signal enemyKilled

@export var max_health := 100
@export var speed := 2.0
@export var attack_range := 1.5
@export var gravity := 9.8
@export var attack_windup := 0.3
@export var attack_damage := 10
@export var attack_cooldown := 1.0
@export var knockback_strength := 2.0
@export var knockback_decay := 8.0

var health := max_health
var player: CharacterBody3D = null

var attack_timer := 0.0
var windup_timer := 0.0
var is_attacking := false
var knockback_velocity := Vector3.ZERO

func _ready():
	add_to_group("enemies")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]

func _physics_process(delta):
	if player == null or health <= 0:
		return

	var dir = player.global_transform.origin - global_transform.origin
	var distance = dir.length()

	# --- Handle cooldown ---
	if attack_timer > 0:
		attack_timer -= delta

	# --- Handle windup and attack execution ---
	if is_attacking:
		windup_timer -= delta
		if windup_timer <= 0:
			perform_attack()
			is_attacking = false
			attack_timer = attack_cooldown

	# --- Trigger new attack only when ready ---
	elif distance <= attack_range and attack_timer <= 0:
		print("Enemy starts attack!")
		is_attacking = true
		windup_timer = attack_windup

	# --- Movement ---
	var move_dir = Vector3.ZERO
	if not is_attacking and distance > attack_range:
		dir.y = 0
		move_dir = dir.normalized() * speed

	# --- Apply knockback ---
	if knockback_velocity.length() > 0.01:
		move_dir += knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_decay * delta)

	velocity.x = move_dir.x
	velocity.z = move_dir.z

	# --- Gravity ---
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# --- Rotation toward player ---
	if distance > 0.1:
		rotation.y = lerp_angle(rotation.y, atan2(-dir.x, -dir.z), delta * 5.0)

	move_and_slide()


func perform_attack():
	if player == null:
		return

	print("Enemy performs attack!")  # DEBUG

	if player.has_method("take_damage"):
		player.take_damage(attack_damage)

	if player.has_method("apply_knockback"):
		var direction = (player.global_transform.origin - global_transform.origin)
		direction.y = 0
		direction = direction.normalized()
		player.apply_knockback(direction * knockback_strength)


func take_damage(amount: int):
	health -= amount
	print("Enemy hit! Health:", health)
	if health <= 0:
		die()

func die():
	enemyKilled.emit()
	queue_free()

func apply_knockback(force: Vector3):
	knockback_velocity += force
