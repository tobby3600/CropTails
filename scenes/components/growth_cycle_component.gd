class_name GrowthCycleComponent
extends Node

@export var current_growth_state : DataTypes.GrowthStates = DataTypes.GrowthStates.Germination
@export_range(5,365) var days_until_harvest : int = 6
# 过几天自动掉落

signal crop_maturity
signal crop_harversting

var is_watered : bool
var starting_day : int
var current_day : int

func _ready() -> void:
	DayAndNightCycleManager.time_tick_day.connect(on_time_tick_day)

func on_time_tick_day(day:int) -> void:
	# 浇水后第一次天数变更时记录为初始天数
	if is_watered:
		if starting_day == 0:
			starting_day = day
		growth_states(starting_day,day)
		harvest_state(starting_day,day)

func growth_states(starting_day:int,current_day:int) -> void:
	if current_growth_state >= DataTypes.GrowthStates.Maturity:
		return  # 一旦成熟或已收获，状态不再改变
	
	var growth_days_passed = (current_day-starting_day)
	var state_index = growth_days_passed + 1
	# 每日阶段+1
	# 成熟所需时间绑定阶段数(4)
	
	current_growth_state = state_index
	var name = DataTypes.GrowthStates.keys()[current_growth_state]
	# print("current_growth_state:",name," state_index：",state_index)
	
	if current_growth_state == DataTypes.GrowthStates.Maturity:
		crop_maturity.emit()
		# 成熟时发送成熟信号
	
func harvest_state(starting_day:int,current_day:int) -> void:
	if current_growth_state == DataTypes.GrowthStates.Harvesting:
		return
	
	var days_passed = (current_day-starting_day)
	if days_passed >= days_until_harvest - 1:
		current_growth_state = DataTypes.GrowthStates.Harvesting
		crop_harversting.emit()
		# 自动收割
	
func get_current_growth_state() -> DataTypes.GrowthStates:
	return current_growth_state
	
	
	
	
	
	
	
	
	
	
	
	
