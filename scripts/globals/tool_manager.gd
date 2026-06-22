extends Node

var selected_tool : DataTypes.Tools = DataTypes.Tools.None
# 全局存储当前选择的工具

signal tool_selected(data: DataTypes.Tools)
# 工具被选择的信号
signal enable_tool(data: DataTypes.Tools)

func select_tool(tool: DataTypes.Tools) -> void:
	tool_selected.emit(tool)
	selected_tool = tool
	#发送信号，更新当前工具

func enable_tool_button(tool: DataTypes.Tools) -> void:
	enable_tool.emit(tool)
