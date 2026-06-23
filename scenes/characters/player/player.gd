class_name Player
extends CharacterBody2D

@onready var hit_component: HitComponent = $HitComponent
@onready var torch_light: PointLight2D = $TorchLight
@export var current_tool : DataTypes.Tools = DataTypes.Tools.None
# 引用自定义类DataTypes中的工具并设置为空

var player_direction : Vector2
var torch_enabled: bool = false  # 火把手动开关状态

# 自动开关时间（小时）
const TORCH_ON_HOUR: float = 18.5   # 晚上 6:30
const TORCH_OFF_HOUR: float = 5.5   # 早上 5:30

func _ready() -> void:
	ToolManager.tool_selected.connect(on_tool_selected)
	DayAndNightCycleManager.game_time.connect(on_game_time)
	# 在玩家上连接选择工具信号
	# print("global_position",global_position)

func _unhandled_input(event: InputEvent) -> void:
	# 按 K 键手动开关火把
	if event.is_action_pressed("toggle_torch"):
		torch_enabled = !torch_enabled
		# 手动操作后禁用自动开关（保存到设置）
		SettingsManager.set_value("general", "auto_torch", false)
		torch_light.visible = torch_enabled

func on_game_time(time: float) -> void:
	# 从设置中读取自动开关状态
	var auto_torch_enabled = SettingsManager.get_value("general", "auto_torch", true)

	# 如果启用了自动开关，根据时间控制火把
	if auto_torch_enabled:
		var total_minutes: int = int(time / DayAndNightCycleManager.GAME_MINUTE_DURATION)
		var current_day_minutes: int = int(total_minutes % DayAndNightCycleManager.MINUTES_PER_DAY)
		var current_hour: float = current_day_minutes / 60.0

		if current_hour >= TORCH_OFF_HOUR && current_hour < TORCH_ON_HOUR:
			torch_light.visible = false
		else:
			torch_light.visible = true

func _process(delta: float) -> void:
	# 火把闪烁效果（减慢频率）
	if torch_light.visible:
		torch_light.energy = 1.0 + sin(Time.get_ticks_msec() * 0.002) * 0.05

func on_tool_selected(tool: DataTypes.Tools) -> void:
	current_tool = tool
	hit_component.current_tool = tool
	#print("Tool select:", tool)
	# 实际执行这个信号
