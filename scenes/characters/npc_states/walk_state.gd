extends NodeState

@export var character: NonPlayableCharacter
@export var animated_sprite_2d: AnimatedSprite2D
@export var navigation_agent_2d: NavigationAgent2D
@export var minspeed:float = 5.0
@export var maxspeed:float = 10.0

var speed:float

func _ready() -> void:
	call_deferred("character_steup")
	navigation_agent_2d.velocity_computed.connect(on_safe_velocity_computed)
	# 在每次更新系统计算好的安全速度时发送信号，更新移动状态

func character_steup() -> void:
	await get_tree().physics_frame
	
	set_movement_target()

func set_movement_target() -> void:
	# 单次设置目标点
	var target_position: Vector2 = NavigationServer2D.map_get_random_point(navigation_agent_2d.get_navigation_map(),navigation_agent_2d.navigation_layers,false)
	# 在区域中随机寻找一个点
	navigation_agent_2d.target_position = target_position
	speed = randf_range(minspeed,maxspeed)

func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	if navigation_agent_2d.is_navigation_finished():
		character.current_walk_cycle += 1
		# 移动到一个路径点后，查看行走循环决定是否继续行走
		set_movement_target()
		return
	
	var target_position: Vector2 = navigation_agent_2d.get_next_path_position()
	var target_direction: Vector2 = character.global_position.direction_to(target_position)
	# 获取目标位置和方向
	
	var velocity: Vector2 = target_direction * speed
	
	if navigation_agent_2d.avoidance_enabled:
		animated_sprite_2d.flip_h = (velocity.x < 0)
		# 根据速度的单位向量x<0翻转图像
		navigation_agent_2d.velocity = velocity
		# 当开启避障时，将速度赋值给导航代理的速度以进行内置的避障
	else:
		character.velocity = velocity
		character.move_and_slide()
		# move_and_slide自带了delta的计算因此无需在此乘以delta
	

func on_safe_velocity_computed(safe_velocity: Vector2) -> void:
	animated_sprite_2d.flip_h = (safe_velocity.x < 0)
	character.velocity = safe_velocity
	character.move_and_slide()
	# 因为链接了velocity.computed到这里，系统会计算好安全速度

func _on_next_transitions() -> void:
	if character.current_walk_cycle == character.walk_cycle:
		# 导航完成时切换回闲置状态
		character.velocity = Vector2.ZERO
		transition.emit("Idle")


func _on_enter() -> void:
	character.current_walk_cycle = 0
	animated_sprite_2d.play("walk")


func _on_exit() -> void:
	animated_sprite_2d.stop()
