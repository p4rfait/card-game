extends Node3D

var deck = []

var colors  = ["red", "green", "blue", "yellow"]
var numbers = ["0","1","2","3","4","5","6","7","8","9"]
var actions = ["skip", "reverse", "draw_two"]
var wilds   = ["wild", "wild_draw_four"]

var CardScene = preload("res://src/scenes/card.tscn")

func _ready() -> void:
	#start_game()
	pass
	
	
func start_game():
	create_card_pool()
	
	
func create_card_pool():
	deck.clear()
	for color in colors:
		deck.append( { "symbol": "0", "color": color } )
		
		for i in range(1, 10):
			for _x in 2:
				deck.append( { "symbol": str(i), "color": color } )
		
		for action in actions:
			for _x in 2:
				deck.append( { "symbol": action, "color": color } )
	
	for wild in wilds:
		for _x in 4:
			deck.append( { "symbol": wild } )
	
	deck.shuffle()

func get_random_card():
	if deck.is_empty():
		return null
	
	var index = randi() % deck.size()
	var card = deck[index]
	deck.remove_at(index)
	return card
