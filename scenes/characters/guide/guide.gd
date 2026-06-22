extends Node2D

var ballon_scene = preload("res://dialogue/game_dialogue_balloon.tscn")

@onready var interactalbe_component: InteractalbeComponet = $InteractalbeComponent
@onready var interactable_label_component: Control = $InteractableLabelComponent

var in_range : bool = false

func _ready() -> void:
	GameDialogueManager.give_crop_seeds.connect(on_give_crop_seeds)

	interactalbe_component.interacrtable_activated.connect(on_interactable_component_activated)
	interactalbe_component.interacrtable_deactivated.connect(on_interactable_component_deactivated)
	interactable_label_component.hide()

	# 延迟一帧检查对话状态，等待存档加载完成
	await get_tree().process_frame
	if GameDialogueManager.get_dialogue_state("guide_crop_seeds_accepted"):
		on_give_crop_seeds()

func on_interactable_component_activated() -> void:
	interactable_label_component.show()
	in_range = true

func on_interactable_component_deactivated() -> void:
	interactable_label_component.hide()
	in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("show_dialogue") && in_range:
		var ballon : BaseGameDialogueBalloon = ballon_scene.instantiate()
		get_tree().root.add_child(ballon)
		# 如果已接受种子，不再触发默认对话
		if GameDialogueManager.get_dialogue_state("guide_crop_seeds_accepted"):
			ballon.start(load("res://dialogue/conversations/guide.dialogue"), "crop_given")
		else:
			ballon.start(load("res://dialogue/conversations/guide.dialogue"), "start")
		
func on_give_crop_seeds() -> void:
	#print("give_crop_seeds received")
	ToolManager.enable_tool_button(DataTypes.Tools.TillGround)
	ToolManager.enable_tool_button(DataTypes.Tools.WaterCrops)
	ToolManager.enable_tool_button(DataTypes.Tools.PlantCorn)
	ToolManager.enable_tool_button(DataTypes.Tools.PlantTomato)
	
