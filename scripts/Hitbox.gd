extends Area3D
class_name Hitbox

@export_enum("head", "body", "legs") var hitbox_type := "body"
@onready var player := get_parent()

func apply_damage(damage_amount, enemy_source: Node, hit_position):
	var multiplier = 1.0
	match hitbox_type:
		"head": multiplier = 2.0
		"body": multiplier = 1.0
		"legs": multiplier = 0.35

	player.take_damage.rpc(int(damage_amount * multiplier), hitbox_type, enemy_source.get_path(), hit_position)
