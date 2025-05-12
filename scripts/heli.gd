extends RigidBody3D

@onready var mesh_rotor: Node3D = $rotor
@onready var mesh_tail: Node3D = $tail
@onready var turret: Node3D = $turret

@export var rotor_spin_speed = 1000.0
@export var tail_spin_speed = -1000.0
@export var forward_accel = 55.0
@export var lift_force = 14.0
@export var max_speed = 75.0
@export var turn_speed = 2.0
@export var spin_up_time = 0.01
@export var target_height = 55.0
@export var strafe_distance = 235.0
@export var max_tilt_angle = deg_to_rad(-5)
@export var tilt_speed = 2.0

@export var tracer_scene: PackedScene
@export var fire_rate = 0.5
@export var tracer_speed = 160.0
@export var miss_chance = 0.35
@export var max_strafe_fire_time = 1.2
@export var burst_count = 6
@export var burst_delay = 0.1

@export var speed_variation = 15.0
@export var height_variation = 10.0
@export var wiggle_amplitude = 2.5
@export var wiggle_speed = 3.0

var rotor_angle = 0.0
var tail_angle = 0.0
var spin_progress = 0.0
var can_fly = false
var current_target: Node3D = null

var rotor_base_rot = Vector3.ZERO
var tail_base_rot = Vector3.ZERO

var strafe_direction = Vector3.FORWARD
var strafe_origin = Vector3.ZERO
var strafing = false
var strafe_time = 0.0

var current_tilt_angle = 0.0
var burst_fired = false
var current_max_speed = 0.0
var current_target_height = 0.0

var wiggle_timer = 0.0
var turn_left_next = true  # Alternate strafes

func _ready():
	rotor_base_rot = mesh_rotor.rotation
	tail_base_rot = mesh_tail.rotation
	center_of_mass = Vector3(0, -0.25, -2.0)
	sleeping = false
	linear_damp = 1.0
	angular_damp = 4.0

func _physics_process(delta):
	if spin_progress < 1.0:
		spin_progress += delta / spin_up_time
	else:
		can_fly = true

	if can_fly:
		current_tilt_angle = lerp_angle(current_tilt_angle, max_tilt_angle, delta * tilt_speed)
		var new_rot = rotation
		new_rot.x = current_tilt_angle
		rotation = new_rot

	rotor_angle = fmod(rotor_angle + rotor_spin_speed * spin_progress * delta, 360.0)
	tail_angle = fmod(tail_angle + tail_spin_speed * spin_progress * delta, 360.0)
	mesh_rotor.rotation = rotor_base_rot
	mesh_rotor.rotate_y(deg_to_rad(rotor_angle))
	mesh_tail.rotation = tail_base_rot
	mesh_tail.rotate_x(deg_to_rad(tail_angle))

	if not can_fly:
		return

	_acquire_target()
	if current_target == null:
		return

	if not strafing:
		_start_strafe()

	var distance_from_origin = global_transform.origin.distance_to(strafe_origin)
	if distance_from_origin >= strafe_distance:
		_start_strafe()

	var flat_dir = Vector3(strafe_direction.x, 0, strafe_direction.z).normalized()
	var target_yaw = atan2(-flat_dir.x, -flat_dir.z)
	var angle_diff = wrapf(target_yaw - rotation.y, -PI, PI)
	rotation.y += clamp(angle_diff, -turn_speed * delta, turn_speed * delta)

	# Wiggle
	wiggle_timer += delta * wiggle_speed
	var wiggle_offset = sin(wiggle_timer) * wiggle_amplitude
	var wiggle_force = transform.basis.x * wiggle_offset
	apply_central_force(wiggle_force)

	# Forward thrust
	var desired_velocity = -transform.basis.z * forward_accel
	linear_velocity = linear_velocity.lerp(desired_velocity, delta * 2.0)

	if linear_velocity.length() > current_max_speed:
		linear_velocity = linear_velocity.normalized() * current_max_speed

	# Height control
	var height_error = current_target_height - global_transform.origin.y
	var lift_adjust = clamp(height_error, -1, 5) * lift_force
	apply_central_force(Vector3.UP * lift_adjust)

	# Pitch stabilization
	var pitch = transform.basis.get_euler().x
	var pitch_damping = -pitch * 0.8
	apply_torque(transform.basis.x * pitch_damping)

	# Fire tracer burst if facing player
	strafe_time += delta
	if not burst_fired and strafe_time >= max_strafe_fire_time and _is_facing_target():
		_fire_burst()
		burst_fired = true

func _start_strafe():
	var to_target = current_target.global_transform.origin - global_transform.origin
	to_target.y = 0
	strafe_direction = to_target.normalized()
	strafe_origin = global_transform.origin
	strafe_time = 0.0
	burst_fired = false
	strafing = true

	current_max_speed = max_speed + randf_range(-speed_variation, speed_variation)
	current_target_height = target_height + randf_range(-height_variation, height_variation)


func _is_facing_target() -> bool:
	var to_target = (current_target.global_transform.origin - global_transform.origin).normalized()
	var forward = -transform.basis.z.normalized()
	var dot = forward.dot(to_target)
	return dot > 0.9  # Fire only if mostly facing target

func _acquire_target():
	if current_target and is_instance_valid(current_target):
		return

	var closest_dist = INF
	for node in get_tree().get_nodes_in_group("players"):
		if not node is Node3D:
			continue
		var dist = global_transform.origin.distance_to(node.global_transform.origin)
		if dist < closest_dist:
			closest_dist = dist
			current_target = node

func _fire_burst():
	if not turret or not current_target or not tracer_scene:
		return
	for i in range(burst_count):
		await get_tree().create_timer(burst_delay * i).timeout
		var tracer = tracer_scene.instantiate()
		get_parent().add_child(tracer)

		var spawn_pos = turret.global_transform.origin
		var target_pos = current_target.global_transform.origin

		if randf() < miss_chance:
			target_pos += Vector3(
				randf_range(-2.5, 2.5),
				randf_range(-2.5, 2.5),
				randf_range(-2.5, 2.5)
			)

		var direction = (target_pos - spawn_pos).normalized()
		var velocity = direction * tracer_speed

		tracer.global_transform.origin = spawn_pos
		tracer.look_at(target_pos, Vector3.UP)

		if tracer.has_method("set_velocity"):
			tracer.set_velocity(velocity)
		elif "velocity" in tracer:
			tracer.velocity = velocity
		elif tracer is RigidBody3D:
			tracer.linear_velocity = velocity
