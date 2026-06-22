class_name Player
extends CharacterBody2D

@onready var hit_component: HitComponent = $HitComponent
@onready var torch_light: PointLight2D = $TorchLight
@export var current_tool : DataTypes.Tools = DataTypes.Tools.None
# 引用自定义类DataTypes中的工具并设置为空

var player_direction : Vector2

func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	DayAndNightCycleManager.game_time.connect(on_game_time)
	# 在玩家上连接选择工具信号
	# print("global_position",global_position)

func on_game_time(time: float) -> void:
	# 获取当天时间（0 到 TAU）
	var day_time := fmod(time, TAU)
	# 白天关闭火把，夜晚开启
	# sin(day_time - PI/2) > 0 表示白天（6:00-18:00）
	torch_light.visible = sin(day_time - PI * 0.5) < -0.2

func _process(delta: float) -> void:
	# 火把闪烁效果（减慢频率）
	if torch_light.visible:
		torch_light.energy = 1.0 + sin(Time.get_ticks_msec() * 0.002) * 0.05

func on_tool_selected(tool: DataTypes.Tools) -> void:
	current_tool = tool
	hit_component.current_tool = tool
	#print("Tool select:", tool)
	# 实际执行这个信号
