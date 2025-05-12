extends Node

var color_textures = {
	"red"    : preload("res://src/assets/images/cards/colors/card_red.png"),
	"green"  : preload("res://src/assets/images/cards/colors/card_green.png"),
	"blue"   : preload("res://src/assets/images/cards/colors/card_blue.png"),
	"yellow" : preload("res://src/assets/images/cards/colors/card_yellow.png")
}

var symbol_textures = {
	"0"        : preload("res://src/assets/images/cards/symbols/card_number_zero.png"),
	"1"        : preload("res://src/assets/images/cards/symbols/card_number_one.png"),
	"2"        : preload("res://src/assets/images/cards/symbols/card_number_two.png"),
	"3"        : preload("res://src/assets/images/cards/symbols/card_number_three.png"),
	"4"        : preload("res://src/assets/images/cards/symbols/card_number_four.png"),
	"5"        : preload("res://src/assets/images/cards/symbols/card_number_five.png"),
	"6"        : preload("res://src/assets/images/cards/symbols/card_number_six.png"),
	"7"        : preload("res://src/assets/images/cards/symbols/card_number_seven.png"),
	"8"        : preload("res://src/assets/images/cards/symbols/card_number_eight.png"),
	"9"        : preload("res://src/assets/images/cards/symbols/card_number_nine.png"),
	"skip"     : preload("res://src/assets/images/cards/symbols/card_skip.png"),
	"reverse"  : preload("res://src/assets/images/cards/symbols/card_reverse.png"),
	"draw_two" : preload("res://src/assets/images/cards/symbols/card_draw_two.png")
}

const wild_textures = {
	"wild"           : preload("res://src/assets/images/cards/wild/card_wild.png"),
	"wild_draw_four" : preload("res://src/assets/images/cards/wild/card_wild_draw_four.png")
}
