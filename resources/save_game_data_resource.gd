class_name SaveGameDataResource
extends Resource

# 实际序列化时保存的内容
@export var save_data_nodes : Array[NodeDataResource]

@export var game_time: float = 0.0
@export var inventory: Dictionary = {}
@export var dialogue_states: Dictionary = {}
# 对时间、库存和对话状态的简易存储
