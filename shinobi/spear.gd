extends Node3D

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var area: Area3D = $hitbox

@export var knockback_strength := 5
@export var damage := 10
@export var hit_pause_duration := 0.07

# Hitbox and combo state
var can_damage := false
var current_attack := 0
var max_combo := 3
var can_chain := false
var rest_transform: Transform3D

func _ready():
	rest_transform = self.transform
	area.monitoring = false
	area.body_entered.connect(_on_body_entered)

# Called when attack button is pressed
func attack():
	if current_attack == 0 or can_chain:
		current_attack += 1
		if current_attack > max_combo:
			current_attack = 1

		match current_attack:
			1: anim.play("swing")
			2: anim.play("swing2")
			3: anim.play("swing3")

		can_damage = true
		area.monitoring = true
		can_chain = false

# Called from AnimationPlayer mid-animation
func enable_next_chain():
	can_chain = true

# Called from AnimationPlayer at end of swing
func end_attack():
	can_damage = false
	area.monitoring = false

	if not can_chain:
		end_combo()

# Reset sword to idle
func end_combo():
	current_attack = 0
	can_chain = false
	self.transform = rest_transform

# Hit detection
func _on_body_entered(body):
	if can_damage:
		var enemy_node = body
		if not enemy_node.is_in_group("enemies") and body.get_parent() != null:
			enemy_node = body.get_parent()

		if enemy_node.is_in_group("enemies"):
			enemy_node.take_damage(damage)

			var direction = (enemy_node.global_transform.origin - global_transform.origin).normalized()
			direction.y = 0.01

			spawn_hit_particles(enemy_node.global_position, direction)

			if enemy_node.has_method("apply_knockback"):
				enemy_node.apply_knockback(direction * knockback_strength)

			# Freeze the game briefly
			hit_pause_global()

func spawn_hit_particles(hit_position: Vector3, hit_direction: Vector3):
	var hit_particles_scene = preload("res://hit_particles.tscn")
	var particles = hit_particles_scene.instantiate()
	get_tree().current_scene.add_child(particles)

	var offset = hit_direction * 0.2 + Vector3(
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

# ------------------------
# GLOBAL HIT STOP FUNCTION
# ------------------------
func hit_pause_global() -> void:
	# Freeze everything
	Engine.time_scale = 0.0

	# Wait using real-world time (ignores time_scale)
	var start_time = Time.get_ticks_msec()
	var duration_ms = int(hit_pause_duration * 1000)
	while Time.get_ticks_msec() - start_time < duration_ms:
		OS.delay_msec(1)

	# Restore normal time
	Engine.time_scale = 1.0
