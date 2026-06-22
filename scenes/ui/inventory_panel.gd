extends PanelContainer

var item_labels : Dictionary

func _ready() -> void:
	InventoryManager.inventory_changed.connect(on_inventory_changed)
	
	# 初始化映射
	item_labels = {
		"log": $MarginContainer/VBoxContainer/Logs/LogLabel,
		"stone": $MarginContainer/VBoxContainer/Stone/StoneLabel,
		"corn": $MarginContainer/VBoxContainer/Corn/CornLabel,
		"tomato": $MarginContainer/VBoxContainer/Tomato/TomatoLabel,
		"egg": $MarginContainer/VBoxContainer/Egg/EggLabel,
		"milk": $MarginContainer/VBoxContainer/Milk/MilkLabel
	}
	# 使用映射表来便捷的管理重复组件
	#print(item_labels)
	

func on_inventory_changed() -> void:
	var inventory: Dictionary = InventoryManager.inventory
	
	for item in item_labels.keys():
		# keys() 遍历键列表(字典第一项)
		var label : Label = item_labels[item]
		
		if inventory.has(item):
			label.text = str(inventory[item])
		else:
			label.text = str(0)
		#print("label:",label," item:", str(item)," inventory count:",str(inventory.get(item, 0)))
	
	
