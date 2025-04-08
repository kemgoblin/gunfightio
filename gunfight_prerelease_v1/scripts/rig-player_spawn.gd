extends Area3D


func _ready() -> void:
	pass
	
func _process(delta: float) -> void:
	pass


func player_in_range() -> bool:
	# Checks its overlapping bodies to see if there's a player in it.
	var sees_player := false
	for object in get_overlapping_bodies():
		if "ctrl_port" in object: sees_player = true
	return sees_player
