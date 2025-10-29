extends CharacterBody3D
class_name Enemy

signal enemy_killed

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@export var attack_cooldown: float = 1.5
@export var speed: float = 5.0
@export var attack_range: float = 2.0
@export var damage: int = 10
@export var health: int = 70
@export var max_health: int = 70
@export var knockback_decay: float = 8.0
@export var detection_range: float = 5.0  # How far the enemy can "see" the player
@export var forget_range: float = 15.0     # Stop chasing if player goes beyond this distance

var is_alerted: bool = false  # Tracks whether the enemy is actively chasing
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sword = $Orientation/Skeleton/EnemySword
@onready var orientation = $Orientation

var target: Node3D = null
var attack_timer: float = 0.0
var is_attacking: bool = false
var knockback_velocity: Vector3 = Vector3.ZERO


func _ready():
	add_to_group("enemies")

	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		target = players[0]

	if sword and sword.has_method("enable_damage"):
		sword.damage = damage
	else:
		push_warning("Sword not found or missing Sword.gd script!")


func _physics_process(delta):
	if not target:
		return

	# Always tick down cooldown timer
	if attack_timer > 0.0:
		attack_timer -= delta
		if attack_timer < 0.0:
			attack_timer = 0.0

	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0.0

	# Handle knockback
	if knockback_velocity.length() > 0.01:
		velocity.x = knockback_velocity.x
		velocity.z = knockback_velocity.z
		knockback_velocity = knockback_velocity.lerp(Vector3.ZERO, knockback_decay * delta)
	else:
		handle_ai_movement(delta)

	move_and_slide()


func handle_ai_movement(delta):
	if not target or is_attacking:
		return

	var to_player = target.global_transform.origin - global_transform.origin
	var distance = to_player.length()

	# Determine if the enemy should be alerted
	if distance <= detection_range:
		is_alerted = true
	elif distance > forget_range:
		is_alerted = false

	# If not alerted, don't move
	if not is_alerted:
		velocity.x = 0
		velocity.z = 0
		return

	# Rotate toward player
	if distance > 0.5:
		var target_yaw = atan2(-to_player.x, -to_player.z)
		orientation.rotation.y = lerp_angle(orientation.rotation.y, target_yaw, delta * 5.0)

	# Attack or move
	if distance <= attack_range:
		try_attack()
	else:
		var move_dir = to_player.normalized()
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed


func try_attack():
	if is_attacking or attack_timer > 0:
		return

	is_attacking = true
	attack_timer = attack_cooldown

	play_animation("attack")

	if sword and sword.has_method("enable_damage"):
		await get_tree().create_timer(0.2).timeout
		sword.enable_damage()
		await get_tree().create_timer(0.6).timeout
		sword.disable_damage()

	# Wait until attack animation finishes
	if anim_player.has_animation("attack"):
		var finished_anim: String = await anim_player.animation_finished
		while finished_anim != "attack":
			finished_anim = await anim_player.animation_finished

	is_attacking = false


func play_animation(anim_name: String):
	if anim_player and anim_player.has_animation(anim_name):
		anim_player.stop()
		await get_tree().process_frame
		anim_player.play(anim_name)


func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy hit! Health now:", health)

	if health <= 0:
		die()


func apply_knockback(force: Vector3) -> void:
	# Apply knockback directly, overriding current AI movement
	knockback_velocity = force


func die():
	enemy_killed.emit()
	queue_free()
