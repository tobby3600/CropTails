class_name DamageComponent
extends Node2D

@export var max_damage = 1
@export var current_damage = 0
# 最大伤害的当前伤害

signal max_damage_reached
# 达到最大伤害的信号

func apply_damage(damage : int) -> void:
	current_damage = clamp(current_damage+damage,0,max_damage)
	# 将当前伤害+传入的伤害限制在0~最大伤害范围内
	
	if current_damage == max_damage:
		max_damage_reached.emit()
		# 如果已经达到最大伤害，发送达到最大伤害的信号
