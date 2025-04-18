extends Node

@export_category("DEBUG")
@export var skip_menu := false
@export var map_name := ""
@export_range(1, 2) var player_count := 1


func _ready() -> void:
	if skip_menu: 
		Game.start_match(map_name, player_count)
		return
	
	var menu = load("res://core/menu.tscn").instantiate()
	add_child(menu)
