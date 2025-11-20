extends Node3D

var player = null
var max_health = 500
var health = max_health
var state = null
var damage = 20
var attacking = false
@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var r_hand: Node3D = $RHand2
@onready var l_hand: Node3D = $LHand2

func _ready() -> void:
	add_to_group("enemies")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	await get_tree().create_timer(5).timeout
	state = "phase1"

		
func _physics_process(_delta: float) -> void:
	if health <= 250:
		state = "phase2"
	if not attacking:
		match state:
			"phase1":
				attacking = true
				var down_time = randi_range(5, 7)
				attack()
				await get_tree().create_timer(down_time).timeout
				attacking = false
			"phase2":
				attacking = true
				var down_time = randi_range(2, 4)
				attack()
				await get_tree().create_timer(down_time).timeout
				attacking = false
			"dead":
				pass

func perform_sweep():
	anim.play("Sweep Attack")

func perform_smash():
	var player_loc = player.global_position
	var hand_to_move = randi_range(1, 2)
	if hand_to_move == 1:
		var resting_pos = l_hand.global_position
		var resting_rot = l_hand.global_rotation_degrees
		var target_rot = Vector3.ZERO
		target_rot.x = -90
		var tween := get_tree().create_tween().set_parallel()
		tween.tween_property(l_hand, "global_position", player_loc, 2.0)
		tween.tween_property(l_hand, "global_rotation_degrees", target_rot, 2.0)
		await get_tree().create_timer(5).timeout
		var tween2 := get_tree().create_tween().set_parallel()
		tween2.tween_property(l_hand, "global_position", resting_pos, 0.5)
		tween2.tween_property(l_hand, "global_rotation_degrees", resting_rot, 0.5)
	elif hand_to_move == 2:
		var resting_pos = r_hand.global_position
		var resting_rot = r_hand.global_rotation_degrees
		var target_rot = Vector3.ZERO
		target_rot.x = -90
		var tween := get_tree().create_tween().set_parallel()
		tween.tween_property(r_hand, "global_position", player_loc, 2.0)
		tween.tween_property(r_hand, "global_rotation_degrees", target_rot, 2.0)
		await get_tree().create_timer(5).timeout
		var tween2 := get_tree().create_tween().set_parallel()
		tween2.tween_property(r_hand, "global_position", resting_pos, 0.5)
		tween2.tween_property(r_hand, "global_rotation_degrees", resting_rot, 0.5)

func attack():
	var attack_choice = randi_range(1, 2)
	if attack_choice == 1: perform_sweep()
	else: perform_smash()

func die(): 
	anim.play("die")
	state = "dead"

func take_damage(amount):
	health -= amount
	print("Boss hit! Health:", health)

func _on_child_hit(body):
	if body.is_in_group("player_attack"):
		take_damage(body.light_damage)

func _on_body_entered(body: Node3D) -> void:
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.scale.y = 0.1
		body.take_damage(damage)
		await get_tree().create_timer(6).timeout
		body.scale.y = 1
		
