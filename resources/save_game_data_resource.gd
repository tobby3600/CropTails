class_name SaveGameDataResource
extends Resource

# 实际序列化时保存的内容
@export var save_data_nodes : Array[NodeDataResource]

@export var game_time: float = 0.0
@export var inventory_slots: Array = []
@export var tool_slots: Array = []
@export var dialogue_states: Dictionary = {}
# 对时间、库存槽位、工具槽位（含等级/伤害）和对话状态的简易存储
