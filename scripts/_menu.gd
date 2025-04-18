extends Control

@onready var player_count := $options/player_count
@onready var map_select := $options/map_select
@onready var points := $options/points
@onready var start_match_button := $options/start_match_button

var menu_items := []
var current_index := 0

func _ready() -> void:
	# Populate menu_items and remove any nulls to avoid crashing
	menu_items = [player_count, map_select, points, start_match_button]
	menu_items = menu_items.filter(func(i): return i != null)

	# Set focus only if the list isn't empty
	if menu_items.size() > 0:
		_set_focus(current_index)

func _unhandled_input(event: InputEvent) -> void:
	if menu_items.size() == 0:
		return

	if event.is_action_pressed("ui_down"):
		current_index = (current_index + 1) % menu_items.size()
		_set_focus(current_index)
	elif event.is_action_pressed("ui_up"):
		current_index = (current_index - 1 + menu_items.size()) % menu_items.size()
		_set_focus(current_index)
	elif event.is_action_pressed("ui_accept"):
		if menu_items[current_index] == start_match_button:
			_on_start_match_button_up()

func _set_focus(index: int) -> void:
	if index >= 0 and index < menu_items.size():
		var item = menu_items[index]
		if item != null:
			item.grab_focus()

func _on_start_match_button_up() -> void:
	# Load and instantiate the load_screen scene
	var load_screen = preload("res://core/load_screen.tscn").instantiate()
	get_tree().root.add_child(load_screen)
	
	# Find the sprite that matches the map name and unhide it
	var map_name = map_select.text
	var sprite_node = load_screen.get_node_or_null(map_name)
	if sprite_node and sprite_node is Sprite2D:
		sprite_node.visible = true
	else:
		print("Error: No matching sprite found for map:", map_name)
	
	# Wait for 7 seconds using a timer
	var timer = Timer.new()
	timer.wait_time = 3.0
	timer.one_shot = true
	add_child(timer)
	timer.start()
	
	# Connect the timer's timeout to start the match
	timer.timeout.connect(func():
		Game.start_match(map_name, player_count.value, points.value)
		load_screen.queue_free()
		queue_free()
	)
