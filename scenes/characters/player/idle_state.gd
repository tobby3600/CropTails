extends NodeState

@export var player : Player
@export var animated_sprite_2d : AnimatedSprite2D

func _on_process(_delta : float) -> void:
	pass


func _on_physics_process(_delta : float) -> void:
	if player.player_direction == Vector2.UP:
		animated_sprite_2d.play("idle_back")
	elif player.player_direction == Vector2.RIGHT:
		animated_sprite_2d.play("idle_right")
	elif player.player_direction == Vector2.LEFT:
		animated_sprite_2d.play("idle_left")
	elif player.player_direction == Vector2.DOWN:
		animated_sprite_2d.play("idle_front")
	else:
		animated_sprite_2d.play("idle_front")
	# 根据player.player_direction播放对应的动画


func _on_next_transitions() -> void:
	# 转换到下一个状态
	GameInputEvent.update()
	GameInputEvent.movement_input()
	
	if GameInputEvent.is_movement_input():
		transition.emit("Walk")
		# 如果玩家在移动，切换到移动状态
	
	if player.current_tool == DataTypes.Tools.Axewood && GameInputEvent.use_tool():
		transition.emit("Chopping")
		# 如果玩家当前工具为斧头，切换到砍伐状态
	
	if player.current_tool == DataTypes.Tools.TillGround && GameInputEvent.use_tool():
		transition.emit("Tilling")
		# 如果玩家当前工具为锄头，切换到耕种状态
	
	if player.current_tool == DataTypes.Tools.WaterCrops && GameInputEvent.use_tool():
		transition.emit("Watering")
		# 如果玩家当前工具为水桶，切换到浇水状态


func _on_enter() -> void:
	pass


func _on_exit() -> void:
	animated_sprite_2d.stop()
