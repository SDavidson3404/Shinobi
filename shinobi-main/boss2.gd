extends Node3D

var player = null
var max_health = 1000
var health = max_health
var state = "phase1"
var damage = 20
var attacking = false
@onready var l_hand: Area3D = $LHand
@onready var r_hand: Area3D = $RHand2
@onready var anim: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	add_to_group("enemies")
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	for child in get_children():
		if child is Area3D:
			child.body_entered.connect(_on_child_hit)

func _physics_process(_delta: float) -> void:
	if health <= 500:
		state = "phase2"
	if not attacking:
		match state:
			"phase1":
				attacking = true
				var down_time = randi_range(5, 10)
				await get_tree().create_timer(down_time).timeout
				phase_1()
				attacking = false
			"phase2":
				attacking = true
				var down_time = randi_range(2, 4)
				await get_tree().create_timer(down_time).timeout
				phase_2()
				attacking = false

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

func phase_1():
	var attack_choice = randi_range(1, 2)
	if attack_choice == 1: perform_sweep()
	else: perform_smash()
	

func phase_2():
	var attack_choice = randi_range(1, 2)
	if attack_choice == 1: perform_smash()
	else: perform_sweep()

func die():
	anim.play("die")

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.has_method("enable_damage_window") and body.can_damage:
		health -= body.light_damage
	if body.is_in_group("player") and body.has_method("take_damage"):
		body.take_damage(damage)

func take_damage(amount):
	health -= amount
	print("Boss hit! Health:", health)

func _on_child_hit(body):
	if body.is_in_group("player_attack"):
		take_damage(body.light_damage)
