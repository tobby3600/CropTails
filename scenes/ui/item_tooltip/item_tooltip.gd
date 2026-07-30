class_name ItemTooltip
extends PanelContainer
# 物品悬浮提示组件 — 可复用，跟随鼠标显示物品名称和描述

@export var offset: Vector2 = Vector2(12, 6)
@export var min_width: float = 160.0

@onready var name_label: Label = $VBoxContainer/NameLabel
@onready var desc_label: Label = $VBoxContainer/DescLabel
@onready var stats_box: HBoxContainer = $VBoxContainer/StatsBox
@onready var stack_label: Label = $VBoxContainer/StatsBox/StackLabel
@onready var level_label: Label = $VBoxContainer/StatsBox/LevelLabel
@onready var damage_label: Label = $VBoxContainer/StatsBox/DamageLabel

var _is_visible: bool = false


func _ready() -> void:
	top_level = true
	desc_label.custom_minimum_size.x = min_width
	hide()


## 显示指定物品的 tooltip
## custom_data 为槽位的自定义属性（NBT），含 level/damage 时才显示对应数值
func show_for_item(item_id: String, custom_data: Dictionary = {}) -> void:
	name_label.text = InventoryManager.get_display_name(item_id)
	desc_label.text = InventoryManager.get_description(item_id)
	_update_stats(item_id, custom_data)
	_is_visible = true
	show()


## 更新属性行：堆叠上限 / 等级 / 伤害，无数据的部分隐藏
func _update_stats(item_id: String, custom_data: Dictionary) -> void:
	# 堆叠上限：上限大于 1 才有意义（工具上限为 1，不显示）
	var max_stack: int = InventoryManager.get_max_stack(item_id)
	if max_stack > 1:
		stack_label.text = tr("TOOLTIP_MAX_STACK") + " " + str(max_stack)
		stack_label.show()
	else:
		stack_label.hide()

	# 等级：custom_data 含 level 才显示（工具）
	if custom_data.has("level"):
		level_label.text = tr("TOOLTIP_LEVEL") + " " + str(custom_data["level"])
		level_label.show()
	else:
		level_label.hide()

	# 伤害：custom_data 含 damage 才显示（工具）
	if custom_data.has("damage"):
		damage_label.text = tr("TOOLTIP_DAMAGE") + " " + str(custom_data["damage"])
		damage_label.show()
	else:
		damage_label.hide()

	# 三个标签全部隐藏时收起整行，避免占位空隙
	stats_box.visible = stack_label.visible or level_label.visible or damage_label.visible


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
