extends CharacterBody3D
class_name Player

# ========================
# MOVEMENT
# ========================
@export var SPEED: float = 10.0
@export var JUMP_VELOCITY: float = 10.0
var knockback_velocity: Vector3 = Vector3.ZERO
var knockback_decay: float = 10.0
var input_vector: Vector2 = Vector2.ZERO

# ========================
# CAMERA
# ========================
@onready var _camera_pivot: Node3D = $CameraPivot
@onready var camera: Camera3D = $CameraPivot/SpringArm3D/Camera3D
@export_range(0.0, 1.0) var mouse_sensitivity: float = 0.01
@export var tilt_limit: float = deg_to_rad(75)

# ========================
# WEAPON
# ========================
@onready var aspects: Node3D = $aspects
@onready var weapon_holster: Node3D = $"aspects/Weapon holster"
var weapons: Array[Node3D] = []
var current_weapon_index: int = 0
var current_weapon: Node3D = null

# ========================
# GRAPPLE
# ========================
@onready var rope_mesh: MeshInstance3D = $RopeMesh
@onready var grapple_ray: RayCast3D = $RayCast3D
@export var grapple_speed: float = 25.0
@export var max_grapple_distance: float = 30.0
@export var grapple_stop_distance: float = 3.0
@export var grapple_cooldown: float = 1.0
@export var grapple_stamina_cost: float = 50.0
var is_grappling: bool = false
var grapple_point: Vector3
var grapple_timer: float = 0.0

# ========================
# STAMINA
# ========================
@export var max_stamina: float = 100.0
var current_stamina: float = max_stamina
@export var stamina_recharge_rate: float = 15.0
@export var stamina_recharge_delay: float = 0.5
var stamina_recharge_timer: float = 0.0
@onready var stamina_bar: ProgressBar = $"../UI/StaminaBar"

# ========================
# HEALTH
# ========================
@export var max_health: int = 100
var health: int = max_health
@onready var healthbar: ProgressBar = $"../UI/Healthbar"

# ========================
# READY
# ========================
func _ready() -> void:
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
		

# ========================
# INPUT
# ========================
func _input(event):
	if event.is_action_pressed("ESCAPE"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	if event.is_action_pressed("click") and Input.mouse_mode == Input.MOUSE_MODE_VISIBLE:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

	if event.is_action_pressed("Weapon Swap"):
		swap_weapon()

	if event.is_action_pressed("grapple"):
		try_grapple()

	if Input.is_action_just_pressed("click") and current_weapon:
		current_weapon.attack(false)
	if Input.is_action_just_pressed("heavy_attack") and current_weapon:
		current_weapon.attack(true)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		_camera_pivot.rotation.x = clampf(_camera_pivot.rotation.x - event.relative.y * mouse_sensitivity, -tilt_limit, tilt_limit)
		_camera_pivot.rotation.y -= event.relative.x * mouse_sensitivity

# ========================
# PHYSICS
# ========================
func _physics_process(delta: float) -> void:
	handle_movement(delta)
	handle_grapple(delta)
	move_and_slide()

	# Recharge stamina
	if stamina_recharge_timer > 0.0:
		stamina_recharge_timer -= delta
	else:
		current_stamina = min(current_stamina + stamina_recharge_rate * delta, max_stamina)
	if stamina_bar:
		stamina_bar.value = current_stamina

# ========================
# MOVEMENT
# ========================
func handle_movement(delta: float) -> void:
	if is_grappling:
		return

	input_vector = Vector2(
		Input.get_action_strength("D") - Input.get_action_strength("A"),
		Input.get_action_strength("W") - Input.get_action_strength("S")
	)

	var move_direction: Vector3 = Vector3.ZERO
	if input_vector != Vector2.ZERO:
		var camera_basis = camera.global_transform.basis
		var forward = -camera_basis.z
		forward.y = 0
		forward = forward.normalized()
		var right = camera_basis.x
		right.y = 0
		right = right.normalized()
		move_direction = (input_vector.x * right + input_vector.y * forward).normalized()

		velocity.x = move_direction.x * SPEED
		velocity.z = move_direction.z * SPEED

		var target_rotation = atan2(-move_direction.x, -move_direction.z)
		aspects.rotation.y = lerp_angle(aspects.rotation.y, target_rotation, delta * 10.0)
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
	var distance = to_target.length()

	if distance > grapple_stop_distance:
		var dir = to_target.normalized()
		velocity = velocity.lerp(dir * grapple_speed, delta * 8.0)
		update_rope()
	else:
		cancel_grapple()

func try_grapple() -> void:
	if is_grappling:
		cancel_grapple()
		return

	# Check stamina
	if current_stamina < grapple_stamina_cost:
		print("Not enough stamina to grapple!")
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

		# Deduct stamina and delay regeneration
		current_stamina = max(current_stamina - grapple_stamina_cost, 0)
		stamina_recharge_timer = stamina_recharge_delay

		print("Grapple start:", grapple_point)
	else:
		print("No grapple target")


func update_rope() -> void:
	if not is_grappling:
		rope_mesh.visible = false
		return
	var start = camera.global_position
	var end = grapple_point
	var verts = PackedVector3Array([start, end])
	var arrays = []
	arrays.resize(Mesh.ARRAY_MAX)
	arrays[Mesh.ARRAY_VERTEX] = verts
	var mesh = ArrayMesh.new()
	mesh.add_surface_from_arrays(Mesh.PRIMITIVE_LINES, arrays)
	if rope_mesh.mesh == null:
		var mat = StandardMaterial3D.new()
		mat.unshaded = true
		mat.albedo_color = Color(0.2, 1.0, 0.8)
		rope_mesh.set_surface_override_material(0, mat)
	rope_mesh.mesh = mesh
	rope_mesh.visible = true

func cancel_grapple() -> void:
	is_grappling = false
	rope_mesh.visible = false

# ========================
# COMBAT / HEALTH
# ========================
func take_damage(amount: int) -> void:
	health = clamp(health - amount, 0, max_health)
	if healthbar:
		healthbar.value = health
	if health <= 0:
		die()

func heal(amount: int) -> void:
	health = clamp(health + amount, 0, max_health)
	if healthbar:
		healthbar.value = health

func die() -> void:
	print("Player died!")
	set_physics_process(false)

func swap_weapon() -> void:
	if weapons.size() <= 1:
		return
	current_weapon.visible = false
	current_weapon_index = (current_weapon_index + 1) % weapons.size()
	current_weapon = weapons[current_weapon_index]
	current_weapon.visible = true
	print("Swapped to:", current_weapon.name)

func apply_knockback(force: Vector3) -> void:
	knockback_velocity = force

func spawn_hit_particles(hit_position: Vector3):
	var hit_particles_scene = preload("res://hit_particles.tscn")
	var particles = hit_particles_scene.instantiate()
	get_tree().current_scene.add_child(particles)
	particles.global_position = hit_position
	particles.emitting = true
