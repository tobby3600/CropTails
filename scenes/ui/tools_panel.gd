extends PanelContainer

@onready var tool_axe: Button = $MarginContainer/HBoxContainer/ToolAxe
@onready var tool_tilling: Button = $MarginContainer/HBoxContainer/ToolTilling
@onready var tool_watering_can: Button = $MarginContainer/HBoxContainer/ToolWateringCan
@onready var tool_corn: Button = $MarginContainer/HBoxContainer/ToolCorn
@onready var tool_tomato: Button = $MarginContainer/HBoxContainer/ToolTomato

var tools : Dictionary

func _ready() -> void:
	ToolManager.enable_tool.connect(on_enable_tool_button)
	
	tools = {
		"1":$MarginContainer/HBoxContainer/ToolAxe,
		"2":$MarginContainer/HBoxContainer/ToolTilling,
		"3":$MarginContainer/HBoxContainer/ToolWateringCan,
		"4":$MarginContainer/HBoxContainer/ToolCorn,
		"5":$MarginContainer/HBoxContainer/ToolTomato
	}
	
	disable_all_tools()
	on_enable_tool_button(DataTypes.Tools.Axewood)

func disable_all_tools() -> void:
	for tool in tools.values():
		if tool != null:
			tool.disabled = true
			tool.focus_mode = Control.FOCUS_NONE

func enable_all_tools() -> void:
	for tool in tools.values():
		if tool != null:
			tool.disabled = false
			tool.focus_mode = Control.FOCUS_ALL

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

func on_enable_tool_button(tool:DataTypes.Tools) -> void :
	var tool_str = str(tool)
	for key in tools.keys():
		#print("key:",key,",tool_str:",tool_str)
		if key == tool_str:
			tools[key].disabled = false
			tools[key].focus_mode = Control.FOCUS_NONE
		
		
