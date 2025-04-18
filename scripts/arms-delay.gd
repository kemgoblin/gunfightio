extends Node3D

var move_speed = 5.0
var rotation_speed = 3.0

func _process(delta):
	if not get_parent():
		return

	var parent_transform = get_parent().global_transform
	var new_position = global_transform.origin.lerp(parent_transform.origin, move_speed * delta)

	var current_quat = global_transform.basis.get_rotation_quaternion()
	var target_quat = parent_transform.basis.get_rotation_quaternion()
	var new_quat = current_quat.slerp(target_quat, rotation_speed * delta)
	var new_basis = Basis(new_quat)

	global_transform = Transform3D(new_basis, new_position)
