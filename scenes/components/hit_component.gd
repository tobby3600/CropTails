class_name HitComponent
extends Area2D

@export var current_tool : DataTypes.Tools = DataTypes.Tools.None
# 使用的工具

# 击打伤害 — 命中时从当前工具的 custom_data["damage"] 动态读取（InventoryManager 工具槽位），
# 无工具或槽位无伤害数据时回退为 1
var hit_damage : int:
	get = _get_hit_damage

func _get_hit_damage() -> int:
	var tool_slot := InventoryManager.get_tool_slot(current_tool)
	if tool_slot:
		return int(tool_slot.get_custom_value("damage", 1))
	return 1
