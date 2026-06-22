extends Node

var inventory: Dictionary = Dictionary()

signal inventory_changed

func add_collectable(collectable_name: String) -> void:
	inventory.get_or_add(collectable_name)
	# get_or_add在未找到匹配元素时会新建一个
	
	if inventory[collectable_name] == null:
		inventory[collectable_name] = 1
		# 如果是新元素，赋值为1
	else:
		inventory[collectable_name] += 1
	
	inventory_changed.emit()
	
func remove_collectable(collectable_name : String) -> void:
	if inventory[collectable_name] == null:
		push_error("Removed a empty collectable:",collectable_name)
		inventory[collectable_name] = 0
	else:
		if inventory[collectable_name] > 0:
			inventory[collectable_name] -= 1
	
	inventory_changed.emit()
