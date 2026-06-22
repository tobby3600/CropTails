class_name PlayerDataResource
extends SceneDataResource

@export var current_tool: int = 0
@export var player_direction: Vector2

# 保存玩家组件: 删除旧玩家并加载这个


func _save_data(node: Node2D) -> void:
	super._save_data(node)
	var player := node as Player
	if player:
		current_tool = player.current_tool
		player_direction = player.player_direction


func _load_data(window: Window) -> void:
	# 用 find_child 查找旧玩家并删除
	var old_player := window.find_child("Player", true, false)
	if old_player:
		old_player.get_parent().remove_child(old_player)
		old_player.queue_free()

	if parent_node_path == null or node_path == null:
		return

	# 用 find_child 查找父节点 GameRoot
	var parent_node := window.find_child("GameRoot", true, false) as Node2D
	if parent_node == null:
		return

	var scene_file_resource := load(scene_file_path) as Resource
	var scene_node := scene_file_resource.instantiate() as Node2D
	if scene_node == null:
		return

	# 先添加到场景树，再设置位置（global_position 需要节点在场景树中才能正确计算）
	parent_node.add_child(scene_node)
	scene_node.global_position = global_position

	var player := scene_node as Player
	if player:
		player.player_direction = player_direction
		ToolManager.select_tool.call_deferred(current_tool)

	SaveGameManager.player_replaced.emit()
	# 发送玩家变更信号
