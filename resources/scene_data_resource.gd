class_name SceneDataResource
extends NodeDataResource

@export var node_name: String
@export var scene_file_path: String

func _save_data(node: Node2D) -> void:
	super._save_data(node)
	
	node_name = node.name
	scene_file_path = node.scene_file_path


func _load_data(window: Window) -> void:
	var parent_node: Node2D
	var scene_node: Node2D

	if parent_node_path != null:
		# get_node_or_null 对动态创建的节点可能返回 null（Godot 4 已知问题）
		# 优先使用 find_child 按名称递归搜索作为主要查找方式
		var path_str := str(parent_node_path)
		var last_slash := path_str.rfind("/")
		if last_slash >= 0:
			var parent_name := path_str.substr(last_slash + 1)
			parent_node = window.find_child(parent_name, true, false) as Node2D
	else:
		return

	if node_path != null:
		var scene_file_resource: Resource = load(scene_file_path)
		if scene_file_resource:
			scene_node = scene_file_resource.instantiate() as Node2D
	else:
		return

	if parent_node != null and scene_node != null:
		# 先添加到场景树，再设置位置（global_position 需要节点在场景树中才能正确计算）
		parent_node.add_child(scene_node)
		scene_node.global_position = global_position
