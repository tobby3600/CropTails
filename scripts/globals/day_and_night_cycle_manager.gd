extends Node

const MINUTES_PER_DAY : int = 24*60
const MINUTES_PER_HOUR : int = 60
const GAME_MINUTE_DURATION : float = TAU / MINUTES_PER_DAY
# TAU = 2 * PI
# 将一天24小时映射到一个完整的圆周

var game_speed : float = 5.0
# 现实1秒等于的游戏分钟数

var initial_day : int = 1
var initial_hour : int = 12
var initial_minute: int = 30
# 初始时间

var time : float = 0.0
var current_minute : int = -1
var current_day : int = 0

signal game_time(time:float)
signal time_tick(day:int,hour:int,minute:int)
signal time_tick_day(day:int)

func _ready() -> void:
	set_initial_time()

func _process(delta: float) -> void:
	time += delta * game_speed * GAME_MINUTE_DURATION
	# time 实际以弧度形式存储
	game_time.emit(time)
	recaculate_time()
	# 更新时间

func set_initial_time() -> void:
	var initial_total_minutes = initial_day * MINUTES_PER_DAY + initial_hour * MINUTES_PER_HOUR + initial_minute
	# 合计初始时间
	time = initial_total_minutes * GAME_MINUTE_DURATION
	
func recaculate_time() -> void:
	var total_minutes:int = int(time/GAME_MINUTE_DURATION)
	var day:int = int(total_minutes/MINUTES_PER_DAY)
	var current_day_minutes:int = int(total_minutes%MINUTES_PER_DAY)
	var hour:int = int(current_day_minutes/MINUTES_PER_HOUR)
	var minute:int = int(current_day_minutes%MINUTES_PER_HOUR)
	# 从分钟计量的总时间转换为天/时/分
	
	if current_minute != minute:
		current_minute = minute
		time_tick.emit(day,hour,minute)
	
	if current_day != day:
		current_day = day
		time_tick_day.emit(day)
	# 只在天或分钟实际发生变更时才更新时间
	
	
