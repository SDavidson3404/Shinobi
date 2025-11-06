extends CharacterBody3D
class_name Player

# ========================
# NODES
# ========================
@onready var orientation: Node3D = $Orientation
@onready var aspects: Node3D = $Orientation/aspects
@onready var anim_player: AnimationPlayer = $Orientation/aspects/AnimationPlayer
@onready var camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@onready var grapple_ray: RayCast3D = $RayCast3D
@onready var weapon_holster: Node3D = $"Orientation/aspects/Weapon holster"
@onready var stamina_bar: ProgressBar = $"../UI/StaminaBar"
@onready var healthbar: ProgressBar = $"../UI/Healthbar"
@onready var sword: Node3D = $"Orientation/aspects/Weapon holster/Sword"
@onready var spear: Node3D = $"Orientation/aspects/Weapon holster/Spear"
@onready var sprite_3d: Sprite3D = $CameraPivot/Sprite3D
@onready var v_box: VBoxContainer = $CameraPivot/VBoxContainer
@onready var red: Sprite2D = $"../UI/red"
@onready var recharged: Label = $"../UI/Recharged"
@onready var needs: Label = $"../UI/needs"

# ========================
# SAVE
# ========================
var scene_to_save := "res//level_1"
var level_1 := "res://level_1"
var level_2 := "res://level_2"
@onready var game_saved: Label = $"../UI/Game Saved"

# =========================
# EXPORT VARS
# =========================
@export var Max_jumps = 1
@export var throw_speed: float = 30.0
@export var throw_gravity: float = -9.8
@export var return_speed: float = 40.0
@export var throw_distance: float = 10.0
@export var WALL_CLIMB_DURATION: float = 1.0
@export var WALL_CLIMB_SPEED: float = 10.0 
@export var wall_check_distance: float = 1.0
@export var SPEED: float = 7.0
@export var JUMP_VELOCITY: float = 20.0
@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.01
@export var tilt_limit: float = deg_to_rad(75)
@export var grapple_speed: float = 25.0
@export var max_grapple_distance: float = 15.0
@export var grapple_stop_distance: float = 3.0
@export var grapple_cooldown: float = 1.0
@export var grapple_stamina_cost: float = 50.0
@export var max_stamina: float = 100.0
@export var dodge_speed: float = 35.0
@export var dodge_duration: float = 0.10
@export var dodge_cooldown: float = 0.6
@export var dodge_stamina_cost: float = 25.0
@export var dodge_invincibility_time: float = 0.2
@export var stamina_recharge_rate: float = 15.0
@export var stamina_recharge_delay: float = 0.5
@export var max_health: int = 100

# ==========================
# VARIABLES
# ==========================
var gravity := -24.8
var Current_jumps = 0
var is_wall_running := false
var wall_run_direction := Vector3.ZERO
var wall_run_timer := 0.0
var can_wall_run := false
const MAX_WALL_RUN_TIME := 1.0
const WALL_RUN_SPEED := 9.0   
const WALL_RUN_GRAVITY := -1.0    
const WALL_ANGLE_THRESHOLD := 0.7 
var thrown_weapon: Node3D = null
var is_weapon_thrown: bool = false
var throw_velocity: Vector3 = Vector3.ZERO
var can_throw := false
var is_weapon_returning: bool = false
var throw_direction: Vector3 = Vector3.ZERO
var thrown_distance: float = 0.0
var weapon_original_transform: Transform3D
var is_wall_climbing: bool = false
var wall_climb_timer: float = 0.0
var climb_wall_normal: Vector3 = Vector3.ZERO
var can_climb: bool = false
var wall_climb_used: bool = false
var input_vector: Vector2 = Vector2.ZERO
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_decay: float = 10.0
var shake_amount: float = 0.0
var shake_decay: float = 5.0
var weapons: Array[Node3D] = []
var current_weapon_index: int = 0
var current_weapon: Node3D = null
var is_grappling: bool = false
var grapple_point: Vector3
var is_paused = false
var current_stamina: float = max_stamina
var stamina_recharge_timer: float = 0.0
var health: int = max_health
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_cooldown_timer: float = 0.0
var dodge_direction: Vector3 = Vector3.ZERO
var invulnerable: bool = false
var invuln_timer: float = 0.0
var burst_cooldown := 0.0

# ========================
# READY
# ========================
func _ready() -> void:
	var current_scene = get_tree().current_scene.name
	if current_scene == "Tutorial":
		scene_to_save = "tutorial"
	if current_scene == "Level 1":
		scene_to_save = level_1
	elif current_scene == "Level 2":
		scene_to_save = level_2
	Collectible.connect("collected", Callable(self, "_on_collectible_collected"))
	sword.connect("hit_landed", Callable(self, "_on_sword_hit"))
	spear.connect("hit_landed", Callable(self, "_on_spear_hit"))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")
	for child in weapon_holster.get_children():
		if child is Node3D:
			if child.name == "Sword":
				weapons.append(child)
			if child.name == "Spear":
				if SkillManager.check_unlocked("spear_unlock"):
					weapons.append(child)
			if child.name == "Dagger":
				if SkillManager.check_unlocked("dagger_unlock"):
					weapons.append(child)
			child.visible = false
	if weapons.size() > 0:
		current_weapon_index = 0
		current_weapon = weapons[current_weapon_index]
		current_weapon.visible = true
	if current_weapon: weapon_original_transform = current_weapon.transform
	var save_data = {
		"current_level" : scene_to_save,
		"skills" : SkillManager.skills
	}
	var file_path = "res://save_game.json"
	var file = FileAccess.open(file_path, FileAccess.ModeFlags.WRITE)
	if file:
		var json_string = JSON.stringify(save_data)  # Convert dictionary to JSON string
		file.store_string(json_string)
		file.close()
		print("Game saved successfully!")
		game_saved.visible = true
		await get_tree().create_timer(1).timeout
		game_saved.visible = false
	else:
		print("Failed to open save file!")
	if SkillManager.check_unlocked("health5"): max_health = 175
	elif SkillManager.check_unlocked("health4"): max_health = 150
	elif SkillManager.check_unlocked("health3"): max_health = 130
	elif SkillManager.check_unlocked("health2"): max_health = 115
	elif SkillManager.check_unlocked("health1"): max_health = 105
	if SkillManager.check_unlocked("stamina5"): max_stamina = 175
	elif SkillManager.check_unlocked("stamina4"): max_stamina = 150
	elif SkillManager.check_unlocked("stamina3"): max_stamina = 130
	elif SkillManager.check_unlocked("stamina2"): max_stamina = 115
	elif SkillManager.check_unlocked("stamina1"): max_stamina = 105
	if SkillManager.check_unlocked("double_jump"): Max_jumps = 2
	can_wall_run = SkillManager.check_unlocked("wall_run")
	can_climb = SkillManager.check_unlocked("wall_scramble")
	can_throw = SkillManager.check_unlocked("weapon_throw")

func _input(event):
	if event.is_action_pressed("ESCAPE"):
		if not is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			v_box.visible = true
			is_paused = true
		else:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			v_box.visible = false
			is_paused = false
	if event.is_action_pressed("click") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		if not is_paused: Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("Weapon Swap"): if not is_paused: swap_weapon()
	if Input.is_action_pressed("grapple"): if not is_paused: try_grapple()
	if Input.is_action_just_pressed("click") and current_weapon: if not is_paused: current_weapon.attack(false)
	if Input.is_action_just_pressed("heavy_attack") and current_weapon: if not is_paused: current_weapon.attack(true)
	if Input.is_action_pressed("dodge"):
		if SkillManager.check_unlocked("dodge"):
			if not is_paused:
				try_dodge()
	if Input.is_action_just_pressed("Space"):
		if can_climb and try_wall_climb():
			return
		elif Current_jumps < Max_jumps:
			velocity.y = JUMP_VELOCITY
			Current_jumps += 1
	if Input.is_action_just_pressed("throw_weapon"): if not is_paused: throw_weapon()
	if Input.is_action_just_pressed("burst_mode"): burst_mode()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - event.relative.y * mouse_sensitivity, -tilt_limit, tilt_limit)
		camera_pivot.rotation.y -= event.relative.x * mouse_sensitivity

func _physics_process(delta: float) -> void:
	if is_on_floor():
		Current_jumps = 0
		wall_climb_used = false
	if can_wall_run:
		check_wall_run_start()
		if is_wall_running:
			update_wall_run(delta)
	handle_wall_climb(delta)
	if not is_wall_climbing and not is_wall_running:
		handle_movement(delta)
		handle_dodge(delta)
		handle_grapple(delta)
	if not is_wall_climbing and not is_wall_running:
		velocity.y += gravity * delta
	move_and_slide()
	if stamina_recharge_timer > 0.0:
		stamina_recharge_timer -= delta
	else:
		current_stamina = min(current_stamina + stamina_recharge_rate * delta, max_stamina)
	if stamina_bar:
		stamina_bar.value = current_stamina
	if dodge_cooldown_timer > 0.0:
		dodge_cooldown_timer -= delta
	if invulnerable:
		invuln_timer -= delta
		if invuln_timer <= 0.0:
			invulnerable = false
	if is_weapon_thrown and thrown_weapon:
		if not is_weapon_returning:
			var travel = throw_direction * throw_speed * delta
			thrown_weapon.global_translate(travel)
			thrown_distance += travel.length()
			if thrown_distance >= throw_distance:
				is_weapon_returning = true
				if "disable_damage_window" in thrown_weapon:
					thrown_weapon.disable_damage_window()
		else:
			var target_pos = weapon_holster.global_transform.origin
			thrown_weapon.global_position = thrown_weapon.global_position.lerp(target_pos, return_speed * delta)
			if thrown_weapon.global_position.distance_to(target_pos) < 0.1:
				thrown_weapon.get_parent().remove_child(thrown_weapon)
				weapon_holster.add_child(thrown_weapon)
				thrown_weapon.transform = weapon_original_transform
				thrown_weapon.visible = true
				is_weapon_thrown = false
				is_weapon_returning = false
				thrown_weapon = null
				thrown_distance = 0.0

func handle_movement(delta: float) -> void:
	if is_dodging or is_grappling or is_wall_climbing:
		return
	if not is_paused:
		input_vector = Vector2(
			Input.get_action_strength("D") - Input.get_action_strength("A"),
			Input.get_action_strength("W") - Input.get_action_strength("S")
		)
	else:
		input_vector = Vector2.ZERO
	var move_dir: Vector3 = Vector3.ZERO
	if input_vector != Vector2.ZERO:
		var cam_basis = camera.global_transform.basis
		var forward = -cam_basis.z; forward.y = 0; forward = forward.normalized()
		var right = cam_basis.x; right.y = 0; right = right.normalized()
		move_dir = (input_vector.x * right + input_vector.y * forward).normalized()
		velocity.x = move_dir.x * SPEED
		velocity.z = move_dir.z * SPEED
		if move_dir.length() > 0.01:
			var target_yaw = atan2(-move_dir.x, -move_dir.z)
			var current_yaw = orientation.rotation.y
			orientation.rotation.y = lerp_angle(current_yaw, target_yaw, delta * 10.0)  # adjust 10.0 for snappiness
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED * delta * 5)
		velocity.z = move_toward(velocity.z, 0, SPEED * delta * 5)
	if Input.is_action_just_pressed("Space") and Current_jumps < Max_jumps:
		if can_climb and try_wall_climb():
			# SKIP normal jump logic
			return
		elif is_on_floor():
			velocity.y = JUMP_VELOCITY
			Current_jumps += 1
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_decay * delta)

func handle_grapple(delta: float) -> void:
	if not is_grappling:
		return
	var to_target = grapple_point - global_transform.origin
	if to_target.length() > grapple_stop_distance:
		velocity = velocity.lerp(to_target.normalized() * grapple_speed, delta * 8.0)
	else:
		cancel_grapple()

func try_grapple() -> void:
	if is_grappling:
		cancel_grapple(); return
	if current_stamina < grapple_stamina_cost:
		return
	var space_state = get_world_3d().direct_space_state
	var ray_origin = camera.global_position
	var ray_end = ray_origin + -camera.global_transform.basis.z * max_grapple_distance
	var query = PhysicsRayQueryParameters3D.new()
	query.from = ray_origin
	query.to = ray_end
	query.exclude = [self]
	var result = space_state.intersect_ray(query)
	if result and result.has("position"):
		grapple_point = result["position"]
		is_grappling = true
		current_stamina -= grapple_stamina_cost
		stamina_recharge_timer = stamina_recharge_delay

func cancel_grapple() -> void:
	is_grappling = false

func try_dodge() -> void:
	$CameraPivot/SpringArm3D.collision_mask = 0
	if is_dodging or is_grappling or dodge_cooldown_timer > 0 or current_stamina < dodge_stamina_cost:
		return
	var input_dir = Vector2(
		Input.get_action_strength("D") - Input.get_action_strength("A"),
		Input.get_action_strength("W") - Input.get_action_strength("S")
	)
	var cam_basis = camera.global_transform.basis
	var forward = -cam_basis.z; forward.y = 0
	var right = cam_basis.x; right.y = 0
	dodge_direction = ( (input_dir.x * right + input_dir.y * forward).normalized() 
						if input_dir.length() > 0.1 else -forward.normalized() )
	is_dodging = true
	dodge_timer = dodge_duration
	dodge_cooldown_timer = dodge_cooldown
	current_stamina -= dodge_stamina_cost
	stamina_recharge_timer = stamina_recharge_delay
	if anim_player and anim_player.has_animation("dodge_roll"):
		anim_player.play("dodge_roll")
	invulnerable = true
	invuln_timer = dodge_invincibility_time

func handle_dodge(delta: float) -> void:
	if not is_dodging:
		return
	orientation.rotation.x = 0
	orientation.rotation.z = 0
	var hor_dir = dodge_direction
	hor_dir.y = 0
	velocity = hor_dir.normalized() * dodge_speed
	if hor_dir.length() > 0.01:
		var target_yaw = atan2(-hor_dir.x, -hor_dir.z)
		orientation.rotation.y = lerp_angle(orientation.rotation.y, target_yaw, delta * 10.0)
	dodge_timer -= delta
	if dodge_timer <= 0.0:
		is_dodging = false
		$CameraPivot/SpringArm3D.collision_mask = 1

func take_damage(amount: int) -> void:
	if invulnerable:
		return
	health = clamp(health - amount, 0, max_health)
	if healthbar: healthbar.value = health
	if health <= 0:
		var current_scene = get_tree().current_scene.name
		if current_scene == "tutorial":
			current_scene = "tutorial.tscn"
		if current_scene == "level 1":
			current_scene = "level_1.tscn"
		elif current_scene == "level 2":
			current_scene = "level_2.tscn"
		elif current_scene == "level_3":
			current_scene = "level_3.tscn"
		SceneManager.change_scene(current_scene)

func heal(amount: int) -> void:
	health = clamp(health + amount, 0, max_health)
	if healthbar: healthbar.value = health

func swap_weapon() -> void:
	if weapons.size() <= 1:
		return
	current_weapon.visible = false
	current_weapon_index = (current_weapon_index + 1) % weapons.size()
	current_weapon = weapons[current_weapon_index]
	current_weapon.visible = true

func _on_collectible_collected():
	max_health += 10
	health += 10
	if healthbar: healthbar.max_value = max_health
	if healthbar: healthbar.value = health
	sprite_3d.visible = true
	await get_tree().create_timer(1).timeout
	sprite_3d.visible = false

func _process(delta):
	if shake_amount > 0.01:
		var offset = Vector3(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount),
			0
		)
		camera_pivot.position = offset
		shake_amount = lerp(shake_amount, 0.0, shake_decay * delta)
	else:
		camera_pivot.position = Vector3.ZERO

func _on_sword_hit(): shake_amount = max(shake_amount, 0.02)

func _on_spear_hit(): shake_amount = max(shake_amount, 0.02)

func _on_close_menu_button_down() -> void:
	is_paused = false
	v_box.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_quit_to_menu_button_down() -> void: SceneManager.change_scene("res://main menu.tscn")

func _on_quit_button_down() -> void: get_tree().quit()

func _on_skill_tree_button_down() -> void: SceneManager.change_scene("res://skill_tree.tscn")

func check_wall_run_start():
	if is_on_floor():
		return
	if is_wall_running:
		return
	var from = global_transform.origin
	var space = get_world_3d().direct_space_state
	var left_dir = -orientation.global_transform.basis.x.normalized()
	var q = PhysicsRayQueryParameters3D.new()
	q.from = from
	q.to = from + left_dir * 1.2
	q.exclude = [self]
	var result = space.intersect_ray(q)
	if result and result.has("position"):
		if is_valid_wall(result["normal"]):
			start_wall_run(result["normal"])
			return
	var right_dir = orientation.global_transform.basis.x.normalized()
	q = PhysicsRayQueryParameters3D.new()
	q.from = from
	q.to = from + right_dir * 1.2
	q.exclude = [self]
	result = space.intersect_ray(q)
	if result and result.has("position"):
		if is_valid_wall(result["normal"]):
			start_wall_run(result["normal"])
			return


func start_wall_run(wall_normal: Vector3):
	is_wall_running = true
	wall_run_timer = 0.0
	wall_run_direction = velocity.slide(wall_normal).normalized()
	velocity = wall_run_direction * WALL_RUN_SPEED

func update_wall_run(delta):
	wall_run_timer += delta
	if wall_run_timer > MAX_WALL_RUN_TIME:
		stop_wall_run()
		return
	velocity = wall_run_direction * WALL_RUN_SPEED
	velocity.y += WALL_RUN_GRAVITY * delta

func stop_wall_run():
	is_wall_running = false

func is_valid_wall(normal: Vector3) -> bool:
	if normal.dot(Vector3.UP) > 0.05:
		return false
	var forward = -orientation.global_transform.basis.z
	forward.y = 0
	forward = forward.normalized()
	var angle_metric = abs(forward.dot(normal))
	return angle_metric < 0.6

func get_climbable_wall() -> Dictionary:
	var origin = global_transform.origin + Vector3(0, 1.0, 0)  # chest height
	var space = get_world_3d().direct_space_state
	var dir = -orientation.global_transform.basis.z  # forward
	var query = PhysicsRayQueryParameters3D.new()
	query.from = origin
	query.to = origin + dir * 1.5  # longer distance
	query.exclude = [self]
	var hit = space.intersect_ray(query)
	if hit and abs(hit.normal.dot(Vector3.UP)) < 0.3:
		return {"hit": true, "normal": hit.normal, "position": hit.position}
	return {"hit": false}


func try_wall_climb() -> bool:
	if is_on_floor() or is_wall_climbing or wall_climb_used:
		return false
	var info = get_climbable_wall()
	if not info.hit:
		return false
	is_wall_climbing = true
	wall_climb_timer = 0.0
	climb_wall_normal = info.normal
	var push_toward_wall = climb_wall_normal * -0.2
	move_and_collide(push_toward_wall)
	velocity.y = WALL_CLIMB_SPEED
	wall_climb_used = true  # mark climb as used for this jump
	return true

func handle_wall_climb(delta: float):
	if not is_wall_climbing:
		return
	velocity.y = WALL_CLIMB_SPEED
	var push_toward_wall = climb_wall_normal * -5 * delta
	move_and_collide(push_toward_wall)
	wall_climb_timer += delta
	if wall_climb_timer >= WALL_CLIMB_DURATION or is_on_floor():
		is_wall_climbing = false

func throw_weapon():
	if is_weapon_thrown or not current_weapon:
		return
	var weapon_global = current_weapon.global_transform
	weapon_holster.remove_child(current_weapon)
	get_parent().add_child(current_weapon)
	current_weapon.global_transform = weapon_global
	throw_direction = -camera.global_transform.basis.z.normalized()
	thrown_weapon = current_weapon
	current_weapon.visible = false
	is_weapon_thrown = true
	is_weapon_returning = false
	thrown_distance = 0.0
	if "enable_damage_window" in thrown_weapon:
		thrown_weapon.enable_damage_window()

func burst_mode():
	# Checks if you have it
	if SkillManager.check_unlocked("burst_mode"):
		# Checks if cooldown is active
		if burst_cooldown <= 0:
			# Perform Burst Mode for 10 seconds
			burst_cooldown = 10.0
			red.visible = true
			current_weapon.light_damage += 5
			current_weapon.heavy_damage += 5
			await get_tree().create_timer(10).timeout
			# Disable Burst Mode and start cooldown
			red.visible = false
			current_weapon.light_damage -= 5
			current_weapon.heavy_damage -= 5
			await get_tree().create_timer(10).timeout
			# Set cooldown to inactive
			burst_cooldown = 0.0
			recharged.visible = true
			await get_tree().create_timer(1).timeout
			recharged.visible = false
		else:
			# Tell user it needs to recharge
			needs.visible = true
			await get_tree().create_timer(1).timeout
			needs.visible = false
