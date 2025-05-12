extends Node

@onready var spawn_points = $"../PlayerSpawnPoints".get_children()
@onready var table_card_holder: Marker3D = $"../TopCardHolder"
var player_scene = preload("res://src/scenes/player.tscn")
var card_scene = preload("res://src/scenes/card.tscn")
var top_card_node: Node3D = null

var players = {}
var player_nodes = {}
var deck = []
var hands = {}
var turn_order = []
var current_turn_index = 0
var game_started = false
var top_card: Dictionary = {}
var direction = 1

const MAX_PLAYERS = 4

func _ready() -> void:
	if OS.has_feature("server"):
		print("Iniciando en Modo Servidor")
		start_server()
	else:
		print("Iniciando en Modo Cliente")
		connect_to_server("192.168.122.217")

	if is_multiplayer_authority():
		_generate_deck()
		multiplayer.peer_connected.connect(_on_peer_connected)
		
func _generate_deck() -> void:
	deck.clear()
	var colors = ["red", "green", "blue", "yellow"]
	var numbers = ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "draw_two", "skip", "reverse"]
	var wilds = ["wild", "wild_draw_four"]
	for color in colors:
		for num in numbers:
			var count = 1 if num == "0" else 2
			for _i in range(count):
				deck.append({"type": "color", "color": color, "symbol": num})
	for wild in wilds:
		for _i in range(4):
			deck.append({"type": "wild", "color": "wild", "symbol": wild})

func start_server() -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(12345, MAX_PLAYERS)
	multiplayer.multiplayer_peer = peer
	print("Servidor Iniciado")

func connect_to_server(ip: String) -> void:
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(ip, 12345)
	multiplayer.multiplayer_peer = peer
	print("Conectando al servidor...")

func _on_peer_connected(id: int) -> void:
	print("Jugador %d conectado." % id)
	if is_multiplayer_authority():
		spawn_player(id)
		var player = players[id]
		rpc_id(id, "spawn_player_for_others", id, player.global_transform.origin, player.global_rotation)
		sync_players(id)
		if players.size() == MAX_PLAYERS and not game_started:
			start_game()

func spawn_player(peer_id: int) -> void:
	if players.size() < MAX_PLAYERS:
		var player = player_scene.instantiate()
		add_child(player)
		player.name = "Player_%s" % peer_id
		player.set_multiplayer_authority(peer_id)
		var spawn_position = spawn_points[players.size() % spawn_points.size()]
		player.global_transform.origin = spawn_position.global_transform.origin
		players[peer_id] = player
		player_nodes[peer_id] = player
		var center = Vector3.ZERO
		player.look_at(center, Vector3.UP)
		rpc("spawn_player_for_others", peer_id, player.global_transform.origin, player.global_rotation)
	else:
		push_warning("Máximo de jugadores alcanzado")

@rpc
func spawn_player_for_others(peer_id: int, position: Vector3, rotation: Vector3) -> void:
	var player = player_scene.instantiate()
	add_child(player)
	player.name = "Player_%s" % peer_id
	player.global_transform.origin = position
	player.global_rotation = rotation
	player_nodes[peer_id] = player
	print("Jugador %d creado en el cliente" % peer_id)

func sync_players(peer_id: int) -> void:
	for player_id in players.keys():
		var player = players[player_id]
		rpc_id(peer_id, "spawn_player_for_others", player_id, player.global_transform.origin, player.global_rotation)
	for other_id in hands.keys():
		for card in hands[other_id]:
			rpc_id(peer_id, "receive_card_for_player", other_id, card)

func _draw_random_card() -> Dictionary:
	if deck.size() == 0:
		print("El mazo está vacío.")
		return {}
	var index = randi() % deck.size()
	return deck.pop_at(index)

func start_game():
	print("La partida comienza!")
	game_started = true
	hands.clear()
	turn_order.clear()
	for id in players.keys():
		hands[id] = []
		turn_order.append(id)
		for i in range(7):
			var card_data = _draw_random_card()
			hands[id].append(card_data)
			player_nodes[id].rpc("receive_card", card_data)
	top_card = _draw_random_card()
	print("Carta inicial: %s" % top_card)
	broadcast_top_card()
	notify_turn(turn_order[current_turn_index])
	print(deck.size())

func notify_turn(player_id: int):
	for id in player_nodes.keys():
		player_nodes[id].rpc("on_turn_changed", player_id)
	print("Turno del jugador %d" % player_id)

func next_turn():
	current_turn_index = (current_turn_index + direction) % turn_order.size()
	notify_turn(turn_order[current_turn_index])

func is_valid_play(card: Dictionary) -> bool:
	if card["type"] == "wild":
		return true
	return card["color"] == top_card["color"] or card["symbol"] == top_card["symbol"]

@rpc
func play_card(player_id: int, card_data: Dictionary):
	if turn_order[current_turn_index] != player_id:
		print("No es el turno del jugador %d" % player_id)
		return
	if not is_valid_play(card_data):
		print("Jugada inválida de %d" % player_id)
		return
	top_card = card_data
	broadcast_top_card()
	hands[player_id].erase(card_data)
	player_nodes[player_id].rpc("remove_card", card_data)
	match card_data["symbol"]:
		"skip":
			current_turn_index = (current_turn_index + direction) % turn_order.size()
		"reverse":
			direction *= -1
		"draw_two":
			var next_id = turn_order[(current_turn_index + direction) % turn_order.size()]
			for i in range(2):
				var c = _draw_random_card()
				hands[next_id].append(c)
				player_nodes[next_id].rpc("receive_card", c)
	next_turn()

func broadcast_top_card():
	for id in player_nodes:
		player_nodes[id].rpc("update_top_card", top_card)
	if is_multiplayer_authority():
		_show_top_card_visual()
	rpc("show_top_card_client", top_card)

@rpc
func show_top_card_client(card_data: Dictionary):
	if top_card_node:
		top_card_node.queue_free()
	top_card_node = card_scene.instantiate()
	table_card_holder.add_child(top_card_node)
	top_card_node.set_card_data(card_data)
	top_card_node.position = Vector3.ZERO
	top_card_node.look_at(Vector3(0, -1, 0), Vector3.FORWARD)
	top_card_node.rotate_y(randf_range(-0.2, 0.2))

func _show_top_card_visual():
	if top_card_node:
		top_card_node.queue_free()
	top_card_node = card_scene.instantiate()
	table_card_holder.add_child(top_card_node)
	top_card_node.set_card_data(top_card)
	top_card_node.position = Vector3.ZERO
	top_card_node.look_at(Vector3(0, -1, 0), Vector3.FORWARD)
	top_card_node.rotate_y(randf_range(-0.2, 0.2))

@rpc
func receive_card_for_player(player_id: int, card_data: Dictionary):
	if player_nodes.has(player_id):
		player_nodes[player_id].add_card_to_hand(card_data)
	else:
		push_warning("No se encontró el jugador %s al intentar sincronizar cartas." % player_id)
