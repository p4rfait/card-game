extends Node3D

@onready var hand: Node3D = $Hand
var card_scene = preload("res://src/scenes/card.tscn")
var cards_in_hand: Array = []

@rpc
func add_card_to_hand(data: Dictionary) -> void:
	receive_card(data)

@rpc
func receive_card(data: Dictionary) -> void:
	var card = card_scene.instantiate()
	hand.add_child(card)
	card.set_card_data(data)
	cards_in_hand.append(card)
	update_hand_positions()

@rpc
func update_top_card(card_data: Dictionary) -> void:
	print("Carta en juego actualizada: %s" % card_data)
	# $TopCardDisplay.update_with(card_data)

@rpc
func on_turn_changed(current_player_id: int) -> void:
	if multiplayer.get_unique_id() == current_player_id:
		print("Es tu turno.")
	else:
		print("Turno del jugador %d" % current_player_id)


func update_hand_positions() -> void:
	var count = cards_in_hand.size()
	if count == 0:
		return
	var spacing = .3
	var spread = spacing * (count - 1)
	var start_x = -spread / 2.0
	var z_offset_base = 0.02
	for i in range(count):
		var card = cards_in_hand[i]
		var x = start_x + i * spacing
		var z = (i - count / 2.0) * z_offset_base
		card.position = Vector3(x, 0, z)
		card.rotation = Vector3.ZERO
