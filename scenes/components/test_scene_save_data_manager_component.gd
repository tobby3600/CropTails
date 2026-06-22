class_name TestSceneSaveDataManagerComponent
extends Node

func _ready() -> void:
	call_deferred("load_test_scene")
	# 用于测试的单次加载存档

func load_test_scene():
	SaveGameManager.load_game()
	
