extends Node

@export var cursor_component_texture : Texture2D
@export var cursor_can_drop_texture: Texture2D
@export var cursor_forbidden_texture : Texture2D

func _ready() -> void:
	Input.set_custom_mouse_cursor(cursor_component_texture, Input.CURSOR_ARROW)
	# Godot 内置拖拽会切换光标形状（拖拽中/可放置/禁止放置），
	# 需要为这三种形状注册同样的自定义光标，否则拖拽时回退为系统默认光标
	Input.set_custom_mouse_cursor(cursor_component_texture, Input.CURSOR_DRAG)
	Input.set_custom_mouse_cursor(cursor_can_drop_texture, Input.CURSOR_CAN_DROP)
	Input.set_custom_mouse_cursor(cursor_forbidden_texture, Input.CURSOR_FORBIDDEN)
	
