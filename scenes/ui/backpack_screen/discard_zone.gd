extends PanelContainer
# 丢弃区 — 接收拖拽物品后在玩家位置掉落

@export var pickup_protection_time: float = 3.0

func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if data is Dictionary and data.has("source_slot_index"):
		var source_index = data["source_slot_index"]
		var slot = InventoryManager.get_slot(source_index)
		if slot and not slot.is_empty():
			# 检查是否有配置掉落物场景
			var drop_scene = InventoryManager.get_item_drop_scene(slot.item_id)
			return drop_scene != null
	return false


func _drop_data(_position: Vector2, data: Variant) -> void:
	if not data is Dictionary:
		return

	var source_index = data["source_slot_index"]
	var slot = InventoryManager.get_slot(source_index)
	if slot == null or slot.is_empty():
		return

	var drop_scene = InventoryManager.get_item_drop_scene(slot.item_id)
	if drop_scene == null:
		return

	# 获取玩家位置
	var player = get_tree().get_first_node_in_group("player")
	if player == null:
		return

	# 实例化掉落物（每个物品单独一个，随机偏移避免立即拾取）
	var count = slot.count
	for i in count:
		var drop_instance = drop_scene.instantiate() as Node2D
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		drop_instance.global_position = player.global_position + offset
		get_tree().root.add_child(drop_instance)

		# 拾取保护：暂时关闭 CollectableComponent 检测
		_apply_pickup_protection(drop_instance)

	# 清空源槽位
	InventoryManager.slots[source_index] = null
	InventoryManager.slot_changed.emit(source_index)
	InventoryManager.inventory_changed.emit()


func _apply_pickup_protection(node: Node) -> void:
	# 查找 CollectableComponent 子节点并暂时禁用
	for child in node.get_children():
		if child is CollectableComponent:
			child.set_deferred("monitoring", false)
			# 使用 scene tree timer 延迟恢复
			node.get_tree().create_timer(pickup_protection_time).timeout.connect(
				func():
					if is_instance_valid(child):
						child.set_deferred("monitoring", true)
			)
			return
		# 递归查找
		_apply_pickup_protection(child)
