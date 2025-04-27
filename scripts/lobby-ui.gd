extends Control

@export var menu: Control
@export var leader_label: Label
@export var room_code_label: Label
@export var create_lobby_button: Button

@export var join_container: Control
@export var join_lobby_button: Button
@export var room_code_input: LineEdit

@export var start_button: Button
@export var leave_button: Button

@export var map_select: LineEdit
@export var points_to_win: SpinBox


func _ready() -> void:
	multiplayer.server_disconnected.connect(on_lobby_disconnected)
	
	Multiplayer.room_code_updated.connect(func():
		room_code_label.text = Multiplayer.room_code
	)
	Multiplayer.player_ids_updated.connect(func():
		on_lobby_connected()
	)
	Game.game_starting.connect(func():
		menu.queue_free()
	)
	
	create_lobby_button.pressed.connect(func():
		Matchmaking.queued_request = Matchmaking.create_lobby_request.rpc_id.bind(1)
		Matchmaking.start_client(Multiplayer.MASTERSERVER_IP, Multiplayer.MASTERSERVER_PORT)
	)
	join_lobby_button.pressed.connect(func():
		Matchmaking.queued_request = Matchmaking.join_lobby_request.rpc_id.bind(1, room_code_input.text)
		Matchmaking.start_client(Multiplayer.MASTERSERVER_IP, Multiplayer.MASTERSERVER_PORT)
	)
	start_button.pressed.connect(func():
		var map_name := map_select.text
		var points := points_to_win.value
		Multiplayer.start_game_request.rpc_id(1, map_name, points)
	)
	leave_button.pressed.connect(func():
		multiplayer.multiplayer_peer.disconnect_peer(1)
	)
	
	if multiplayer.multiplayer_peer is OfflineMultiplayerPeer:
		on_lobby_disconnected()
	else:
		on_lobby_connected()


func on_lobby_connected() -> void:
	var is_leader := false
	if not Multiplayer.player_ids.is_empty():
		if Multiplayer.player_ids[0] == multiplayer.get_unique_id():
			is_leader = true
	leader_label.visible = is_leader
	room_code_label.text = Multiplayer.room_code
	room_code_label.show()
	create_lobby_button.hide()
	join_container.hide()
	start_button.visible = is_leader
	leave_button.show()


func on_lobby_disconnected() -> void:
	leader_label.hide()
	room_code_label.hide()
	create_lobby_button.show()
	join_container.show()
	start_button.hide()
	leave_button.hide()
