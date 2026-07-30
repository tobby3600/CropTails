class_name BackpackSlot
extends PanelContainer
# 背包槽位控件 — 支持拖拽交换、锁定功能和物品悬停提示

@export var slot_index: int = -1
@export var is_locked: bool = false

@onready var texture_rect: TextureRect = $TextureRect
@onready var count_label: Label = $CountLabel
@onready var lock_overlay: TextureRect = $LockOverlay

var _tooltip: ItemTooltip


func _ready() -> void:
	InventoryManager.inventory_changed.connect(_on_inventory_changed)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	_update_display()


func set_tooltip(tooltip: ItemTooltip) -> void:
	_tooltip = tooltip


func _on_mouse_entered() -> void:
	if _tooltip:
		var slot = InventoryManager.get_slot(slot_index)
		if slot and not slot.is_empty():
			_tooltip.show_for_item(slot.item_id, slot.custom_data)


func _on_mouse_exited() -> void:
	if _tooltip:
		_tooltip.hide_tooltip()


func _on_inventory_changed() -> void:
	_update_display()


func _update_display() -> void:
	if slot_index < 0 or slot_index >= InventoryManager.SLOT_COUNT:
		return

	var slot = InventoryManager.get_slot(slot_index)

	if slot and not slot.is_empty():
		var icon = InventoryManager.get_item_icon(slot.item_id)
		if icon:
			texture_rect.texture = icon
			texture_rect.show()
		else:
			texture_rect.hide()
		# 数量大于 1 才显示数字（工具等 count=1 的不显示）
		if slot.count > 1:
			count_label.text = str(slot.count)
			count_label.show()
		else:
			count_label.hide()
	else:
		texture_rect.hide()
		count_label.text = ""

	lock_overlay.visible = is_locked


# ============================================================
#  拖拽支持
# ============================================================

func _get_drag_data(_position: Vector2) -> Variant:
	if is_locked:
		return null

	var slot = InventoryManager.get_slot(slot_index)
	if slot == null or slot.is_empty():
		return null

	# 创建浮动预览
	var preview = TextureRect.new()
	preview.texture = texture_rect.texture
	preview.custom_minimum_size = Vector2(24, 24)
	preview.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	set_drag_preview(preview)

	return {
		"source_slot_index": slot_index,
		"slot_data": slot
	}


func _can_drop_data(_position: Vector2, data: Variant) -> bool:
	if is_locked:
		return false
	if data is Dictionary and data.has("source_slot_index"):
		return true
	return false


func _drop_data(_position: Vector2, data: Variant) -> void:
	if not data is Dictionary:
		return

	var source_index = data["source_slot_index"]
	var target_index = slot_index

	if source_index == target_index:
		return

	# 交换槽位数据
	var source_slot = InventoryManager.get_slot(source_index)
	var target_slot = InventoryManager.get_slot(target_index)

	InventoryManager.slots[source_index] = target_slot
	InventoryManager.slots[target_index] = source_slot

	InventoryManager.slot_changed.emit(source_index)
	InventoryManager.slot_changed.emit(target_index)
	InventoryManager.inventory_changed.emit()
