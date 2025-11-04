extends CharacterBody3D
class_name Player

# ========================
# SAVE
# ========================
var scene_to_save := "res//level_1"
var level_1 := "res://level_1"
var level_2 := "res://level_2"
@onready var game_saved: Label = $"../UI/Game Saved"

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

# ========================
# MOVEMENT
# ========================
@export var SPEED: float = 7.0
@export var JUMP_VELOCITY: float = 10.0
var input_vector: Vector2 = Vector2.ZERO
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_decay: float = 10.0

# ========================
# CAMERA
# ========================
@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.01
@export var tilt_limit: float = deg_to_rad(75)
var shake_amount: float = 0.0
var shake_decay: float = 5.0

# ========================
# WEAPON
# ========================
var weapons: Array[Node3D] = []
var current_weapon_index: int = 0
var current_weapon: Node3D = null

# ========================
# GRAPPLE
# ========================
@export var grapple_speed: float = 25.0
@export var max_grapple_distance: float = 15.0
@export var grapple_stop_distance: float = 3.0
@export var grapple_cooldown: float = 1.0
@export var grapple_stamina_cost: float = 50.0
var is_grappling: bool = false
var grapple_point: Vector3

# ========================
# MENU
# ========================
var is_paused = false
@onready var v_box: VBoxContainer = $CameraPivot/VBoxContainer

# ========================
# STAMINA
# ========================
@export var max_stamina: float = 100.0
var current_stamina: float = max_stamina
@export var stamina_recharge_rate: float = 15.0
@export var stamina_recharge_delay: float = 0.5
var stamina_recharge_timer: float = 0.0

# ========================
# HEALTH
# ========================
@export var max_health: int = 100
var health: int = max_health

# ========================
# DODGE
# ========================
@export var dodge_speed: float = 35.0
@export var dodge_duration: float = 0.10
@export var dodge_cooldown: float = 0.6
@export var dodge_stamina_cost: float = 25.0
@export var dodge_invincibility_time: float = 0.2
var is_dodging: bool = false
var dodge_timer: float = 0.0
var dodge_cooldown_timer: float = 0.0
var dodge_direction: Vector3 = Vector3.ZERO
var invulnerable: bool = false
var invuln_timer: float = 0.0

# ========================
# READY
# ========================
func _ready() -> void:
	var current_scene = get_tree().current_scene.name
	if current_scene == "Level 1":
		scene_to_save = level_1
	elif current_scene == "Level 2":
		scene_to_save = level_2
	Collectible.connect("collected", Callable(self, "_on_collectible_collected"))
	sword.connect("hit_landed", Callable(self, "_on_sword_hit"))
	spear.connect("hit_landed", Callable(self, "_on_spear_hit"))
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	add_to_group("player")
	# Setup weapons
	for child in weapon_holster.get_children():
		if child is Node3D:
			weapons.append(child)
			child.visible = false
	if weapons.size() > 0:
		current_weapon_index = 0
		current_weapon = weapons[current_weapon_index]
		current_weapon.visible = true
		
	var save_data = {
		"current_level" : scene_to_save
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
# ========================
# INPUT
# ========================
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
		if not is_paused:
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("Weapon Swap"):
		if not is_paused:
			swap_weapon()
	if event.is_action_pressed("grapple"):
		if not is_paused:
			try_grapple()
	if Input.is_action_just_pressed("click") and current_weapon:
		if not is_paused:
			current_weapon.attack(false)
	if Input.is_action_just_pressed("heavy_attack") and current_weapon:
		if not is_paused:
			current_weapon.attack(true)
	if event.is_action_pressed("dodge"):
		if not is_paused:
			try_dodge()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		camera_pivot.rotation.x = clampf(camera_pivot.rotation.x - event.relative.y * mouse_sensitivity, -tilt_limit, tilt_limit)
		camera_pivot.rotation.y -= event.relative.x * mouse_sensitivity

# ========================
# PHYSICS
# ========================
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_grapple(delta)
	handle_dodge(delta)
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

# ========================
# MOVEMENT
# ========================
func handle_movement(delta: float) -> void:
	if is_dodging or is_grappling:
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
	if Input.is_action_just_pressed("Space") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	if not is_on_floor():
		velocity.y += get_gravity().y * delta
	else:
		velocity.y = max(velocity.y, 0)
	velocity += knockback_velocity
	knockback_velocity = knockback_velocity.move_toward(Vector3.ZERO, knockback_decay * delta)

# ========================
# GRAPPLE
# ========================
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

# ========================
# DODGE
# ========================
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
	# Rotate orientation without tilting mesh
	orientation.rotation.x = 0
	orientation.rotation.z = 0
	var hor_dir = dodge_direction
	hor_dir.y = 0
	velocity = hor_dir.normalized() * dodge_speed
# Smooth rotation while dodging
	if hor_dir.length() > 0.01:
		var target_yaw = atan2(-hor_dir.x, -hor_dir.z)
		orientation.rotation.y = lerp_angle(orientation.rotation.y, target_yaw, delta * 10.0)
	dodge_timer -= delta
	if dodge_timer <= 0.0:
		is_dodging = false
		$CameraPivot/SpringArm3D.collision_mask = 1

# ========================
# COMBAT / HEALTH
# ========================
func take_damage(amount: int) -> void:
	if invulnerable:
		return
	health = clamp(health - amount, 0, max_health)
	if healthbar: healthbar.value = health
	if health <= 0:
		var current_scene = get_tree().current_scene.name
		if current_scene == "level 1":
			current_scene = "level_1.tscn"
		elif current_scene == "level 2":
			current_scene = "level_2.tscn"
		elif current_scene == "level_3":
			current_scene = "level_3.tscn"
		get_tree().change_scene_to_file(current_scene)

func heal(amount: int) -> void:
	health = clamp(health + amount, 0, max_health)
	if healthbar: healthbar.value = health

# ========================
# WEAPON
# ========================
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


func _on_sword_hit():
	shake_amount = max(shake_amount, 0.02)

func _on_spear_hit():
	shake_amount = max(shake_amount, 0.02)

func _on_close_menu_button_down() -> void:
	is_paused = false
	v_box.visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _on_quit_to_menu_button_down() -> void:
	get_tree().change_scene_to_file("res://main menu.tscn")


func _on_quit_button_down() -> void:
	get_tree().quit()
