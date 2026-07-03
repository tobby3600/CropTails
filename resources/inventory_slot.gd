class_name InventorySlot
extends Resource
# 库存槽位 — 每个槽位独立持有物品ID、数量和自定义属性（NBT）

@export var item_id: String = ""
@export var count: int = 0
@export var custom_data: Dictionary = {}


func _init(p_item_id: String = "", p_count: int = 0, p_data: Dictionary = {}) -> void:
	item_id = p_item_id
	count = p_count
	custom_data = p_data


func is_empty() -> bool:
	return item_id == "" or count <= 0


func get_custom_value(key: String, default = null):
	return custom_data.get(key, default)


func set_custom_value(key: String, value) -> void:
	custom_data[key] = value


func to_dict() -> Dictionary:
	if is_empty():
		return {}
	return {
		"item_id": item_id,
		"count": count,
		"custom_data": custom_data.duplicate()
	}


static func from_dict(data: Dictionary) -> InventorySlot:
	if data.is_empty():
		return null
	return InventorySlot.new(
		data.get("item_id", ""),
		data.get("count", 0),
		data.get("custom_data", {})
	)
