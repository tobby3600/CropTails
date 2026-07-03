class_name CollectableComponent
extends Area2D

@export var collectable_name : String
@export var item_custom_data : Dictionary = {}


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		InventoryManager.add_item(collectable_name, 1, item_custom_data)
		print("Collected:",collectable_name)
		get_parent().queue_free()
		# 完成收集后，将父组件删除
