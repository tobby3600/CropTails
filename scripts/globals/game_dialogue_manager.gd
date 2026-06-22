extends Node

signal give_crop_seeds
signal feed_the_animals

# 对话状态存储
var dialogue_states: Dictionary = {}

func set_dialogue_state(key: String, value: bool) -> void:
	dialogue_states[key] = value

func get_dialogue_state(key: String, default: bool = false) -> bool:
	return dialogue_states.get(key, default)

func action_give_crop_seeds() -> void:
	dialogue_states["guide_crop_seeds_accepted"] = true
	give_crop_seeds.emit()

func action_feed_the_animals() -> void:
	feed_the_animals.emit()
