class_name InteractalbeComponet
extends Area2D

signal interacrtable_activated
signal interacrtable_deactivated
# 俩个信号用于可交互组件的激活和停止


func _on_body_entered(body: Node2D) -> void:
	interacrtable_activated.emit()


func _on_body_exited(body: Node2D) -> void:
	interacrtable_deactivated.emit()
