class_name DayNightCycleComponent
extends CanvasModulate

@export var initial_day:int = 1:
	set(id):
		initial_day = id
		DayAndNightCycleManager.initial_day = id
		DayAndNightCycleManager.set_initial_time()
# setter快速调用

@export var initial_hour:int = 12:
	set(ih):
		initial_hour = ih
		DayAndNightCycleManager.initial_hour = ih
		DayAndNightCycleManager.set_initial_time()

@export var initial_minute:int = 30:
	set(im):
		initial_minute = im
		DayAndNightCycleManager.initial_minute = im
		DayAndNightCycleManager.set_initial_time()

@export var day_night_gradient_texture : GradientTexture1D
@export var sun_light_curve: Curve  # 日光强度曲线（0=午夜, 0.5=日出/日落, 1=中午）
@export var moon_light_curve: Curve  # 月光强度曲线

@onready var sun_light: DirectionalLight2D = $SunLight
@onready var moon_light: DirectionalLight2D = $MoonLight

func _ready() -> void:
	DayAndNightCycleManager.initial_day = initial_day
	DayAndNightCycleManager.initial_hour = initial_hour
	DayAndNightCycleManager.initial_minute = initial_minute
	DayAndNightCycleManager.set_initial_time()

	DayAndNightCycleManager.game_time.connect(on_game_time)

func on_game_time(time:float) -> void:
	# 获取当天时间（0 到 TAU）
	var day_time := fmod(time, TAU)

	var sample_value : float = 0.5 * (sin(day_time - PI*0.5) + 1.0)
	# 将时间从sin()的[-1,1]映射到渐变条的[0,1]
	# 渐变条上颜色的读取顺序是”0→12 点从左到右，12→24 点从右到左”的来回扫描
	color = day_night_gradient_texture.gradient.sample(sample_value)

	# 将 day_time 映射到 0-1 范围用于曲线采样
	# 0 = 午夜, 0.25 = 6:00, 0.5 = 中午, 0.75 = 18:00, 1 = 午夜
	var curve_sample := day_time / TAU

	# 使用曲线控制光照强度
	sun_light.energy = sun_light_curve.sample(curve_sample)
	moon_light.energy = moon_light_curve.sample(curve_sample)
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
	
