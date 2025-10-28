# Enemy.gd
extends CharacterBody3D
class_name Enemy

@export var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var sword = $Orientation/Skeleton/EnemySword  # No type hint
@export var attack_cooldown: float = 1.5
@export var speed: float = 5.0
@export var attack_range: float = 2.0
@export var damage: int = 10
@export var health: int = 70  # enemy health
@export var max_health: int = 50
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_decay: float = 10.0

var attack_timer: float = 0.0
var is_attacking: bool = false
var target: Node3D = null

func _ready():
	# Replace with your actual player path
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

	# Decrease attack timer
	if attack_timer > 0:
		attack_timer -= delta

	# Apply knockback to velocity (additive)
	velocity.x += knockback_velocity.x
	velocity.z += knockback_velocity.z

	# Smoothly decay knockback (use 0.0 as float!)
	knockback_velocity.x = lerp(knockback_velocity.x, 0.0, knockback_decay * delta)
	knockback_velocity.z = lerp(knockback_velocity.z, 0.0, knockback_decay * delta)




	# Apply gravity
	if not is_on_floor():
		velocity.y -= gravity * delta
	else:
		velocity.y = 0

	# Movement toward player
	var to_player = target.global_transform.origin - global_transform.origin
	var distance = to_player.length()

	if distance > 0.11:
		var target_yaw = atan2(-to_player.x, -to_player.z)
		$Orientation.rotation.y = lerp_angle($Orientation.rotation.y, target_yaw, delta * 5.0)

	if distance <= attack_range:
		try_attack()
	else:
		var move_dir = to_player.normalized()
		velocity.x = move_dir.x * speed
		velocity.z = move_dir.z * speed

	move_and_slide()


func play_animation(anim_name: String):
	if anim_player and anim_player.has_animation(anim_name):
		# Force restart the animation
		anim_player.stop()
		# Wait one frame to ensure stop is processed
		await get_tree().process_frame
		anim_player.play(anim_name, 0.0, 1.0, false)


func try_attack():
	if is_attacking or attack_timer > 0:
		return

	is_attacking = true
	attack_timer = attack_cooldown

	# Play attack animation
	play_animation("attack")

	# Enable sword damage at the correct hit frame
	if sword and sword.has_method("enable_damage"):
		await get_tree().create_timer(0.2).timeout
		sword.enable_damage()
		await get_tree().create_timer(0.6).timeout
		sword.disable_damage()

	# Wait until the attack animation finishes
	if anim_player.has_animation("attack"):
		var finished_anim: String = await anim_player.animation_finished
		while finished_anim != "attack":
			finished_anim = await anim_player.animation_finished

	is_attacking = false




		
func take_damage(amount: int) -> void:
	health -= amount
	print("Enemy hit! Health now:", health)
	
	if health <= 0:
		die()

func apply_knockback(force: Vector3) -> void:
	knockback_velocity += force

func die():
	queue_free()
