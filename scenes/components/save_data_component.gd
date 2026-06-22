class_name SaveDataComponent
extends Node

@onready var parent_node: Node2D = get_parent() as Node2D

@export var save_data_resource: Resource

func _ready() -> void:
	add_to_group("save_data_component")


func _save_data() -> Resource:
	if parent_node == null:
		return null
	
	if save_data_resource == null:
		push_error("save_data_resource:", save_data_resource, parent_node.name)
		return null
	
	# 检查是否拥有 _save_data 方法
	if not save_data_resource.has_method("_save_data"):
		push_error("Resource %s does not have _save_data method. Actual type: %s" % [save_data_resource.resource_path, save_data_resource.get_class()])
		return null
	
	save_data_resource._save_data(parent_node)
	
	return save_data_resource
