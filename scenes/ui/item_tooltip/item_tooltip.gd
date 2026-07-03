class_name ItemTooltip
extends PanelContainer
# 物品悬浮提示组件 — 可复用，跟随鼠标显示物品名称和描述

@export var offset: Vector2 = Vector2(12, 6)
@export var min_width: float = 160.0

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var desc_label: Label = $VBoxContainer/DescLabel

var _is_visible: bool = false


func _ready() -> void:
	top_level = true
	desc_label.custom_minimum_size.x = min_width
	hide()


## 显示指定物品的 tooltip
func show_for_item(item_id: String) -> void:
	name_label.text = InventoryManager.get_display_name(item_id)
	desc_label.text = InventoryManager.get_description(item_id)
	_is_visible = true
	show()


## 隐藏 tooltip
func hide_tooltip() -> void:
	_is_visible = false
	hide()


func _process(_delta: float) -> void:
	if not _is_visible:
		return

	# 跟随鼠标
	global_position = get_global_mouse_position() + offset

	# 防止超出屏幕
	var tip_rect = get_global_rect()
	var screen_size = get_viewport().get_visible_rect().size
	if tip_rect.end.x > screen_size.x:
		global_position.x = get_global_mouse_position().x - tip_rect.size.x - offset.x
	if tip_rect.end.y > screen_size.y:
		global_position.y = get_global_mouse_position().y - tip_rect.size.y - offset.y
