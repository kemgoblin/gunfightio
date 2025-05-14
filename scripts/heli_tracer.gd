extends Node3D

var velocity: Vector3 = Vector3.ZERO
@export var lifetime := 10.0
@export var damage := 20

func _ready():
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _physics_process(delta):
	var space_state = get_world_3d().direct_space_state
	var from = global_transform.origin
	var to = from + velocity * delta

	var query := PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]
	query.collide_with_bodies = true
	query.collide_with_areas = false

	var result = space_state.intersect_ray(query)

	if result:
		var collider = result.collider

		if collider is Player:
			var hit_pos = result.position
			var local_y = collider.to_local(hit_pos).y

			var hit_area = "body"
			if local_y > 1.5:
				hit_area = "head"
			elif local_y < 0.5:
				hit_area = "legs"

			collider.take_damage.rpc_id(
				collider.get_multiplayer_authority(),
				damage,
				hit_area,
				get_path(),
				hit_pos
			)

		queue_free()
	else:
		# Only move forward if no hit
		global_translate(velocity * delta)
