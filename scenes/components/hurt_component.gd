class_name HurtComponent
extends Area2D

@export var tool : DataTypes.Tools = DataTypes.Tools.None
# 需要使用的工具

signal hurt
# 受击信号

func _on_area_entered(area: Area2D) -> void:
	var hit_component = area as HitComponent
	print("hurt tool:"+str(hit_component.current_tool)+",need tool:"+str(tool))
	
	if tool == hit_component.current_tool:
		hurt.emit(hit_component.hit_damage)
		# 如果需要使用的工具与传入组件获取的工具一致，触发on_hurt信号
		# 并将伤害量通过信号发送
