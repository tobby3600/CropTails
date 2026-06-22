class_name CropsCursorComponent
extends Node

@export var tilled_soil_tilemap_layer : TileMapLayer

@onready var player : Player


func _ready() -> void:
	SaveGameManager.player_replaced.connect(_on_player_replaced)
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")


func _on_player_replaced() -> void:
	player = get_tree().get_first_node_in_group("player")

var corn_plant_scene = preload("res://scenes/objects/plants/corn.tscn")
var tomato_plant_scene = preload("res://scenes/objects/plants/tomato.tscn")

var mouse_position : Vector2
var cell_position : Vector2i
var cell_source_id : int
var local_cell_position : Vector2
var distance : float

const CELL_SOURCE_ID_TILLED_DIRT : int = 10


func _get_crop_fields() -> Node2D:
	var parent := get_parent()
	var crop_fields := parent.find_child("CropFields") as Node2D
	if crop_fields == null:
		crop_fields = Node2D.new()
		crop_fields.name = "CropFields"
		parent.add_child(crop_fields)
	return crop_fields


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("remove_dirt"):
		if ToolManager.selected_tool == DataTypes.Tools.TillGround:
			get_cell_under_mouse()
			remove_crop()
	elif event.is_action_pressed("hit"):
		if ToolManager.selected_tool == DataTypes.Tools.PlantCorn or ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
			get_cell_under_mouse()
			add_crop()

func get_cell_under_mouse() -> void:
	mouse_position = tilled_soil_tilemap_layer.get_local_mouse_position()
	cell_position = tilled_soil_tilemap_layer.local_to_map(mouse_position)
	cell_source_id = tilled_soil_tilemap_layer.get_cell_source_id(cell_position)
	local_cell_position = tilled_soil_tilemap_layer.map_to_local(cell_position)
	distance = player.global_position.distance_to(local_cell_position)

func add_crop() -> void:
	if distance <= 20.0 && cell_source_id == CELL_SOURCE_ID_TILLED_DIRT:
		var crop_fields := _get_crop_fields()
		var _quit = false
		for node: Node2D in crop_fields.get_children():
			if node.global_position.distance_to(local_cell_position) <= 3:
				_quit = true
		if ToolManager.selected_tool == DataTypes.Tools.PlantCorn && !_quit:
			var corn_instance = corn_plant_scene.instantiate() as Node2D
			corn_instance.global_position = local_cell_position
			crop_fields.add_child(corn_instance)
		elif ToolManager.selected_tool == DataTypes.Tools.PlantTomato && !_quit:
			var tomato_instance = tomato_plant_scene.instantiate() as Node2D
			tomato_instance.global_position = local_cell_position
			crop_fields.add_child(tomato_instance)

func remove_crop() -> void:
	if distance <= 20.0 && cell_source_id == CELL_SOURCE_ID_TILLED_DIRT:
		for node: Node2D in _get_crop_fields().get_children():
			if node.global_position == local_cell_position:
				node.queue_free()
				return
