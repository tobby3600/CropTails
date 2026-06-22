class_name CropDataResource
extends SceneDataResource

@export var is_watered: bool = false
@export var current_growth_state: int = 0
@export var starting_day: int = 0


func _save_data(node: Node2D) -> void:
	super._save_data(node)
	var growth := node.find_child("GrowthCycleComponent") as GrowthCycleComponent
	if growth:
		is_watered = growth.is_watered
		current_growth_state = growth.current_growth_state
		starting_day = growth.starting_day


func _load_data(window: Window) -> void:
	# 完全覆写 _load_data，在 add_child 后、_ready() 前恢复生长状态
	var parent_node: Node2D = null
	if parent_node_path != null:
		var path_str := str(parent_node_path)
		var last_slash := path_str.rfind("/")
		if last_slash >= 0:
			var parent_name := path_str.substr(last_slash + 1)
			parent_node = window.find_child(parent_name, true, false) as Node2D
	if parent_node == null:
		return

	var scene_file_resource := load(scene_file_path) as Resource
	var scene_node := scene_file_resource.instantiate() as Node2D
	if scene_node == null:
		return

	scene_node.global_position = global_position
	parent_node.add_child(scene_node)

	# 在 _ready() 前直接恢复生长状态
	var growth := scene_node.find_child("GrowthCycleComponent") as GrowthCycleComponent
	if growth:
		growth.is_watered = is_watered
		growth.current_growth_state = current_growth_state
		growth.starting_day = starting_day
