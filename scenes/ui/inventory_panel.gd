extends PanelContainer

# 物品栏槽位 UI：槽位索引 9-15（ITEM_SLOT_START 起始）
# 每项为 [SlotNode, TextureRect, CountLabel]
var slot_ui : Array = []
@export var tooltip_offset: Vector2 = Vector2(12, 6)
@export var tooltip_min_width: float = 160.0
var hovered_slot_index: int = -1

@onready var tooltip: PanelContainer = $Tooltip
@onready var tooltip_name_label: Label = $Tooltip/VBoxContainer/NameLabel
@onready var tooltip_desc_label: Label = $Tooltip/VBoxContainer/DescLabel


func _ready() -> void:
	# Tooltip 脱离父容器布局，避免撑大面板
	tooltip.top_level = true
	tooltip_desc_label.custom_minimum_size.x = tooltip_min_width
	tooltip.hide()

	InventoryManager.inventory_changed.connect(on_inventory_changed)

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
			# 初始隐藏图标和数量
			slot_ui[i][1].hide()
			slot_ui[i][2].hide()

			# 连接鼠标悬停信号
			slot_node.mouse_entered.connect(_on_slot_mouse_entered.bind(i))
			slot_node.mouse_exited.connect(_on_slot_mouse_exited.bind(i))

	on_inventory_changed()


func _on_slot_mouse_entered(slot_index: int) -> void:
	hovered_slot_index = slot_index
	var slot = InventoryManager.get_slot(slot_index)
	if slot and not slot.is_empty():
		tooltip_name_label.text = InventoryManager.get_display_name(slot.item_id)
		tooltip_desc_label.text = InventoryManager.get_description(slot.item_id)
		tooltip.show()


func _on_slot_mouse_exited(slot_index: int) -> void:
	if hovered_slot_index == slot_index:
		hovered_slot_index = -1
		tooltip.hide()


func _process(_delta: float) -> void:
	if hovered_slot_index < 0:
		return

	# 鼠标离开面板区域时隐藏
	var mouse_pos = get_global_mouse_position()
	if not get_global_rect().has_point(mouse_pos):
		hovered_slot_index = -1
		tooltip.hide()
		return

	# tooltip 跟随鼠标
	tooltip.global_position = mouse_pos + tooltip_offset
	# 防止超出屏幕
	var tip_rect = tooltip.get_global_rect()
	var screen_size = get_viewport().get_visible_rect().size
	if tip_rect.end.x > screen_size.x:
		tooltip.global_position.x = mouse_pos.x - tip_rect.size.x - tooltip_offset.x
	if tip_rect.end.y > screen_size.y:
		tooltip.global_position.y = mouse_pos.y - tip_rect.size.y - tooltip_offset.y


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
