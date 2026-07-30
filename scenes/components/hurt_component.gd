class_name HurtComponent
extends Area2D

# 接受的工具及伤害倍率：键 = DataTypes.Tools 枚举值（int），值 = 伤害倍率（float）
# 例：{ DataTypes.Tools.Axewood: 1.0 } 表示接受斧头且伤害 ×1
# 可配置多个工具来源，每个工具独立的伤害倍率
@export var tool_damage_multipliers : Dictionary = {}

signal hurt
# 受击信号

func _on_area_entered(area: Area2D) -> void:
	var hit_component = area as HitComponent
	if hit_component == null:
		return
	print("hurt tool:" + str(hit_component.current_tool) + ", accepted tools:" + str(tool_damage_multipliers.keys()))

	if tool_damage_multipliers.has(hit_component.current_tool):
		var multiplier : float = tool_damage_multipliers[hit_component.current_tool]
		var damage : int = roundi(hit_component.hit_damage * multiplier)
		hurt.emit(damage)
		# 如果传入组件的工具在接受列表中，触发 hurt 信号
		# 实际伤害 = 工具伤害 × 该工具配置的倍率
