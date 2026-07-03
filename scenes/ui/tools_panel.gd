extends PanelContainer

@onready var tool_axe: Button = $MarginContainer/HBoxContainer/ToolAxe
@onready var tool_tilling: Button = $MarginContainer/HBoxContainer/ToolTilling
@onready var tool_watering_can: Button = $MarginContainer/HBoxContainer/ToolWateringCan
@onready var tool_corn: Button = $MarginContainer/HBoxContainer/ToolCorn
@onready var tool_tomato: Button = $MarginContainer/HBoxContainer/ToolTomato
@onready var tool_name_label: Label = $ToolNameLabel

@export var switch_text_duration: float = 1.5

# 槽位索引 → 按钮节点
var tools : Dictionary
# DataTypes.Tools 枚举 → 槽位索引
var tool_slot_map : Dictionary = {
	DataTypes.Tools.Axewood:     0,
	DataTypes.Tools.TillGround:  1,
	DataTypes.Tools.WaterCrops:  2,
	DataTypes.Tools.PlantCorn:   3,
	DataTypes.Tools.PlantTomato: 4,
}
# DataTypes.Tools 枚举 → item_id
var tool_item_map : Dictionary = {
	DataTypes.Tools.Axewood:     "axe",
	DataTypes.Tools.TillGround:  "tilling",
	DataTypes.Tools.WaterCrops:  "watering_can",
	DataTypes.Tools.PlantCorn:   "corn_seeds",
	DataTypes.Tools.PlantTomato: "tomato_seeds",
}

var _switch_timer: Timer
var _last_tool: DataTypes.Tools = DataTypes.Tools.None


func _ready() -> void:
	ToolManager.enable_tool.connect(on_enable_tool_button)
	ToolManager.tool_selected.connect(_on_tool_selected)

	tools = {
		0: $MarginContainer/HBoxContainer/ToolAxe,
		1: $MarginContainer/HBoxContainer/ToolTilling,
		2: $MarginContainer/HBoxContainer/ToolWateringCan,
		3: $MarginContainer/HBoxContainer/ToolCorn,
		4: $MarginContainer/HBoxContainer/ToolTomato
	}

	_switch_timer = Timer.new()
	_switch_timer.one_shot = true
	_switch_timer.timeout.connect(_on_switch_timer_timeout)
	add_child(_switch_timer)

	# 将 Label 定位到面板上方居中
	tool_name_label.global_position = global_position + Vector2(0, -tool_name_label.size.y - 9)
	tool_name_label.size.x = size.x

	disable_all_tools()
	on_enable_tool_button(DataTypes.Tools.Axewood)


func _process(_delta: float) -> void:
	tool_name_label.global_position = global_position + Vector2(0, -tool_name_label.size.y - 9)
	tool_name_label.size.x = size.x


func disable_all_tools() -> void:
	for button in tools.values():
		if button != null:
			button.disabled = true
			button.focus_mode = Control.FOCUS_NONE


func enable_all_tools() -> void:
	for button in tools.values():
		if button != null:
			button.disabled = false
			button.focus_mode = Control.FOCUS_ALL


func _on_tool_selected(tool: DataTypes.Tools) -> void:
	_switch_timer.stop()

	if tool == DataTypes.Tools.None:
		tool_name_label.hide()
		_last_tool = DataTypes.Tools.None
		return

	var item_id = tool_item_map.get(tool, "")
	if item_id == "":
		tool_name_label.hide()
		return

	var name_text = InventoryManager.get_display_name(item_id)
	tool_name_label.text = tr("SWITCHED_TO") + name_text
	tool_name_label.show()

	_switch_timer.start(switch_text_duration)
	_last_tool = tool


func _on_switch_timer_timeout() -> void:
	if _last_tool == DataTypes.Tools.None:
		return
	var item_id = tool_item_map.get(_last_tool, "")
	if item_id == "":
		return
	tool_name_label.text = InventoryManager.get_display_name(item_id)


func _on_tool_axe_pressed() -> void:
	if ToolManager.selected_tool == DataTypes.Tools.Axewood:
		ToolManager.select_tool(DataTypes.Tools.None)
		tool_axe.release_focus()
	else:
		ToolManager.select_tool(DataTypes.Tools.Axewood)

func _on_tool_tilling_pressed() -> void:
	if ToolManager.selected_tool == DataTypes.Tools.TillGround:
		ToolManager.select_tool(DataTypes.Tools.None)
		tool_tilling.release_focus()
	else:
		ToolManager.select_tool(DataTypes.Tools.TillGround)

func _on_tool_watering_can_pressed() -> void:
	if ToolManager.selected_tool == DataTypes.Tools.WaterCrops:
		ToolManager.select_tool(DataTypes.Tools.None)
		tool_watering_can.release_focus()
	else:
		ToolManager.select_tool(DataTypes.Tools.WaterCrops)

func _on_tool_corn_pressed() -> void:
	if ToolManager.selected_tool == DataTypes.Tools.PlantCorn:
		ToolManager.select_tool(DataTypes.Tools.None)
		tool_corn.release_focus()
	else:
		ToolManager.select_tool(DataTypes.Tools.PlantCorn)

func _on_tool_tomato_pressed() -> void:
	if ToolManager.selected_tool == DataTypes.Tools.PlantTomato:
		ToolManager.select_tool(DataTypes.Tools.None)
		tool_tomato.release_focus()
	else:
		ToolManager.select_tool(DataTypes.Tools.PlantTomato)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			ToolManager.select_tool(DataTypes.Tools.None)
			tool_axe.release_focus()
			tool_tilling.release_focus()
			tool_watering_can.release_focus()
			tool_corn.release_focus()
			tool_tomato.release_focus()
			# 右键取消选择工具

func on_enable_tool_button(tool: DataTypes.Tools) -> void:
	var slot_index = tool_slot_map.get(tool, -1)
	if slot_index == -1:
		return
	if tools.has(slot_index) and tools[slot_index] != null:
		tools[slot_index].disabled = false
		tools[slot_index].focus_mode = Control.FOCUS_NONE
