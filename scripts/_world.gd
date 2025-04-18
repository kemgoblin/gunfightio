extends Node3D

## NODES ##
var current_map : Map
@onready var p0_vp := $viewports/player_0/vp
@onready var p1_vp := $viewports/player_1/vp

## GAME ##
var target_score := 10


func _ready() -> void:
	# Set up the map.
	add_child(current_map)
	
	for player in Game.player_roster:
		self["p"+str(player.ctrl_port)+"_vp"].add_child(player)
		player.camera.current = true
		respawn(player, str(player.ctrl_port))
	
	# Add screen covers, if necessary.
	$viewports/player_1/screen_cover.hide()
	if p1_vp.get_child_count() <= 0:
		$viewports/player_1/screen_cover.show()
	
	$death_zone.connect("body_entered", catch_player)


func respawn(player, spawn_override:=""):
	# Spawns the player at a random point on the map.
	var spawn_array = current_map.get_node("spawns").get_children()
	var target_spawn = spawn_array[randi_range(0, spawn_array.size()-1)]
	
	if spawn_override != "":
		target_spawn = current_map.get_node("spawns").get_node(spawn_override)
	else:
		while target_spawn.player_in_range():
			target_spawn = spawn_array[randi_range(0, spawn_array.size()-1)]
	player.global_transform = target_spawn.global_transform 
	
	
	var rad = target_spawn.get_node("shape").shape.radius
	player.global_transform.origin += Vector3(randf_range(-rad, rad), 0, randf_range(-rad, rad))


func end_game(winner: Player):
	# Find the loser
	var loser = null
	for player in Game.player_roster:
		if player != winner:
			loser = player
			break

	# Safety check
	if winner == null or loser == null:
		print("Error: Winner or Loser is null.")
		return

	# Find the correct HUD nodes for winner and loser
	var winner_hud = self["p" + str(winner.ctrl_port) + "_vp"].find_child("hud", true, false)
	var loser_hud = self["p" + str(loser.ctrl_port) + "_vp"].find_child("hud", true, false)

	# Ensure HUD nodes exist before proceeding
	if winner_hud and loser_hud:
		var victory_node = winner_hud.get_node("victory")
		var defeat_node = loser_hud.get_node("defeat")
		
		# Set initial transparency for fade-in effect
		victory_node.modulate.a = 0.0
		defeat_node.modulate.a = 0.0

		# Show the nodes
		victory_node.show()
		defeat_node.show()

		# Play the victory audio (child of winner_hud)
		var victory_audio = winner_hud.get_node("victory_audio")
		if victory_audio:
			victory_audio.play()
		else:
			print("Warning: victory_audio node not found.")

		# Tween the alpha value from 0 to 1 over 1 second for both elements
		var tween = get_tree().create_tween()
		tween.tween_property(victory_node, "modulate:a", 1.0, 1.0)
		tween.tween_property(defeat_node, "modulate:a", 1.0, 1.0)
		
		# Wait for the fade-in to complete and then an extra 5 seconds before ending the match
		await tween.finished
		await get_tree().create_timer(5.0).timeout
		Game.end_match()
	else:
		print("Error: hud not found for winner or loser.")




func catch_player(player):
	if not player is Player: return
	respawn(player)
