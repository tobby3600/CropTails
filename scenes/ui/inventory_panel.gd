extends PanelContainer

# 物品栏槽位 UI：槽位索引 ITEM_SLOT_START 起始
# 每项为 [SlotNode, TextureRect, CountLabel]
var slot_ui : Array = []

var _tooltip: ItemTooltip
var _hovered_slot_index: int = -1


func _ready() -> void:
	InventoryManager.inventory_changed.connect(on_inventory_changed)

	# 创建 ItemTooltip 组件
	var tooltip_scene = preload("res://scenes/ui/item_tooltip/item_tooltip.tscn")
	_tooltip = tooltip_scene.instantiate()
	add_child(_tooltip)

	# 按槽位顺序初始化 UI 引用
	var base = $MarginContainer/VBoxContainer
	slot_ui.resize(InventoryManager.SLOT_COUNT)

	for i in range(InventoryManager.ITEM_SLOT_START, InventoryManager.ITEM_SLOT_END + 1):
		var slot_node = base.get_node_or_null("Slot%d" % i)
		if slot_node:
			slot_ui[i] = [
				slot_node,
				slot_node.get_node("TextureRect"),
				slot_node.get_node("CountLabel")
			]
			slot_ui[i][1].hide()
			slot_ui[i][2].hide()

			slot_node.mouse_entered.connect(_on_slot_mouse_entered.bind(i))
			slot_node.mouse_exited.connect(_on_slot_mouse_exited.bind(i))

	on_inventory_changed()


func _on_slot_mouse_entered(slot_index: int) -> void:
	_hovered_slot_index = slot_index
	var slot = InventoryManager.get_slot(slot_index)
	if slot and not slot.is_empty():
		_tooltip.show_for_item(slot.item_id, slot.custom_data)


func _on_slot_mouse_exited(slot_index: int) -> void:
	if _hovered_slot_index == slot_index:
		_hovered_slot_index = -1
		_tooltip.hide_tooltip()


func _process(_delta: float) -> void:
	if _hovered_slot_index >= 0:
		if not get_global_rect().has_point(get_global_mouse_position()):
			_hovered_slot_index = -1
			_tooltip.hide_tooltip()


func on_inventory_changed() -> void:
	for i in range(InventoryManager.ITEM_SLOT_START, InventoryManager.ITEM_SLOT_END + 1):
		if slot_ui[i] == null:
			continue

		var tex_rect : TextureRect = slot_ui[i][1]
		var count_label : Label = slot_ui[i][2]
		var slot = InventoryManager.get_slot(i)

		if slot and not slot.is_empty():
			var icon = InventoryManager.get_item_icon(slot.item_id)
			if icon:
				tex_rect.texture = icon
			tex_rect.show()
			count_label.text = str(slot.count)
			count_label.show()
		else:
			tex_rect.hide()
			count_label.hide()
