extends CanvasLayer
# 背包界面 — 按 I 键打开的覆盖层，包含选项卡：背包 / 预留1 / 预留2

const BackpackSlotScene = preload("res://scenes/ui/backpack_slot/backpack_slot.tscn")
const ItemTooltipScene = preload("res://scenes/ui/item_tooltip/item_tooltip.tscn")

var _all_slots: Array[BackpackSlot] = []
var _tooltip: ItemTooltip


func _ready() -> void:
	# 动态查找节点
	var panel = $BackpackPanel
	var margin = panel.get_node("MarginContainer")
	var vbox = margin.get_node("VBoxContainer")
	var header = vbox.get_node("Header")
	var tab_container = vbox.get_node("TabContainer")

	# 关闭按钮
	var close_button = header.get_node("CloseButton")
	close_button.pressed.connect(close)

	# 背景遮罩点击关闭
	var bg = $BackgroundOverlay
	bg.gui_input.connect(_on_background_input)

	# 选项卡标题
	tab_container.set_tab_title(0, tr("BACKPACK"))
	tab_container.set_tab_title(1, tr("RESERVED_TAB"))
	tab_container.set_tab_title(2, tr("RESERVED_TAB"))

	# 获取背包选项卡内容 — Content 本身就是 HBoxContainer
	var backpack_tab = tab_container.get_node("BackpackTab")
	var content = backpack_tab.get_node("Content")
	var tool_column = content.get_node("ToolColumn")
	var item_area = content.get_node("ItemArea")
	var item_grid = item_area.get_node("ItemGrid")
	var discard_zone = tool_column.get_node("DiscardZone")

	# 创建工具栏槽位网格（7个，锁定，2列布局）
	var tool_grid = GridContainer.new()
	tool_grid.columns = 2
	tool_grid.add_theme_constant_override("h_separation", 2)
	tool_grid.add_theme_constant_override("v_separation", 2)
	# 插入到 ToolTitle 和 Spacer 之间
	var spacer = tool_column.get_node("Spacer")
	tool_column.add_child(tool_grid)
	tool_column.move_child(tool_grid, spacer.get_index())

	for i in range(InventoryManager.TOOL_SLOT_START, InventoryManager.TOOL_SLOT_END + 1):
		var slot = BackpackSlotScene.instantiate() as BackpackSlot
		slot.slot_index = i
		slot.is_locked = true
		tool_grid.add_child(slot)
		_all_slots.append(slot)

	# 创建物品栏槽位（23个）
	for i in range(InventoryManager.ITEM_SLOT_START, InventoryManager.ITEM_SLOT_END + 1):
		var slot = BackpackSlotScene.instantiate() as BackpackSlot
		slot.slot_index = i
		slot.is_locked = false
		item_grid.add_child(slot)
		_all_slots.append(slot)

	# 丢弃区标签
	var discard_label = discard_zone.get_node("Label")
	discard_label.text = tr("DISCARD")

	# 创建 ItemTooltip 并传递给所有槽位
	_tooltip = ItemTooltipScene.instantiate()
	add_child(_tooltip)
	for slot in _all_slots:
		slot.set_tooltip(_tooltip)


func _on_background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		close()


func close() -> void:
	queue_free()
