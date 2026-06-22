class_name GameInputEvent

static var direction : Vector2

# 记录按键按下的顺序，最后按下的在末尾
static var _pressed_order : Array[StringName] = []

# 方向动作名称到向量的映射
static var _action_to_dir : Dictionary = {
	&"walk_left": Vector2.LEFT,
	&"walk_right": Vector2.RIGHT,
	&"walk_up": Vector2.UP,
	&"walk_down": Vector2.DOWN,
}

# 需要每帧调用，检测按键按下/释放事件
static func update() -> void:
	for action in _action_to_dir:
		if Input.is_action_just_pressed(action):
			# 按下时，如果不在列表中则添加到末尾
			if action not in _pressed_order:
				_pressed_order.append(action)
		elif Input.is_action_just_released(action):
			# 释放时从列表中移除
			_pressed_order.erase(action)

static func movement_input() -> Vector2:
	# 从按下顺序中取最后按下的方向
	if _pressed_order.is_empty():
		direction = Vector2.ZERO
	else:
		var last_action : StringName = _pressed_order.back()
		direction = _action_to_dir.get(last_action, Vector2.ZERO)
	return direction

static func is_movement_input() -> bool :
	if direction == Vector2.ZERO:
		return false
	else:
		return true

static func is_mouse_over_ui() -> bool:
	# 检查鼠标是否悬停在可交互的 UI 控件上（Button、Panel 等）
	var viewport = Engine.get_main_loop().root.get_viewport()
	var hovered = viewport.gui_get_hovered_control()
	if hovered == null:
		return false
	# 只有具体的可交互控件才算，容器类不算
	return hovered is Button or hovered is BaseButton or hovered is Panel or hovered is PanelContainer

static func use_tool() -> bool :
	# 如果鼠标在 UI 上，不触发工具使用
	if is_mouse_over_ui():
		return false
	var use_tool_value : bool = Input.is_action_just_pressed("hit")
	return use_tool_value
	# 返回是否在使用工具
