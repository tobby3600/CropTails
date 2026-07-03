class_name BackpackSlot
extends PanelContainer
# 背包槽位控件 — 支持拖拽交换和锁定功能

@export var slot_index: int = -1
@export var is_locked: bool = false

@onready var texture_rect: TextureRect = $TextureRect
@onready var count_label: Label = $CountLabel
@onready var lock_overlay: TextureRect = $LockOverlay


func _ready() -> void:
	InventoryManager.inventory_changed.connect(_on_inventory_changed)
	_update_display()


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
		count_label.text = str(slot.count)
		count_label.show()
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
