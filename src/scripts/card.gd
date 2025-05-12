extends Node3D

@onready var color_plane: MeshInstance3D = $ColorPlane
@onready var symbol_plane: MeshInstance3D = $SymbolPlane

var card_data: Dictionary

func set_card_data(data: Dictionary) -> void:
	card_data = data

	var color = data.get("color", "")
	var symbol = data.get("symbol", "")
	var type = data.get("type", "")

	print("Asignando carta:", data)

	if type == "wild":
		color_plane.visible = true
		symbol_plane.visible = false

		var wild_texture = Globals.wild_textures.get(symbol, null)
		if wild_texture:
			var wild_mat = color_plane.get_active_material(0).duplicate()
			wild_mat.albedo_texture = wild_texture
			color_plane.set_surface_override_material(0, wild_mat)
			print("Textura WILD aplicada:", symbol)
		else:
			push_warning("No se encontró la textura wild para: " + symbol)
	else:
		color_plane.visible = true
		symbol_plane.visible = true

		var color_texture = Globals.color_textures.get(color, null)
		var symbol_texture = Globals.symbol_textures.get(symbol, null)

		if color_texture:
			var color_mat = color_plane.get_active_material(0).duplicate()
			color_mat.albedo_texture = color_texture
			color_plane.set_surface_override_material(0, color_mat)
			print("Textura color aplicada:", color)
		else:
			push_warning("No se encontró la textura de color para: " + color)

		if symbol_texture:
			var symbol_mat = symbol_plane.get_active_material(0).duplicate()
			symbol_mat.albedo_texture = symbol_texture
			symbol_plane.set_surface_override_material(0, symbol_mat)
			print("Textura símbolo aplicada:", symbol)
		else:
			push_warning("No se encontró la textura de símbolo para: " + symbol)
