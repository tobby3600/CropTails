class_name SaveLevelDataComponent
extends Node
# 单个关卡的存储管理器

var level_scene_name: String
var save_game_data_path: String = "user://game_data/"
var save_file_name: String = "save_%s_game_data.tres"
# 用于拼接最终保存文件的名称

var game_data_resource: SaveGameDataResource
# 实际最终进行序列化并存储的内容


func _ready() -> void:
	add_to_group("save_level_data_component")
	level_scene_name = get_parent().name
	# 关卡名称


func save_node_data() -> void:
	var nodes = get_tree().get_nodes_in_group("save_data_component")
	
	game_data_resource = SaveGameDataResource.new()
	
	if nodes != null:
		for node: SaveDataComponent in nodes:
			if node is SaveDataComponent:
				# 过滤掉不在 MainScene/GameRoot 下的节点（如 GameMenuScreen 中的静态 Player）
				var node_path := str(node.get_parent().get_path())
				if "GameMenuScreen" in node_path:
					continue

				var save_data_resource: NodeDataResource = node._save_data()
				var save_final_resource = save_data_resource.duplicate()
				game_data_resource.save_data_nodes.append(save_final_resource)
	
	game_data_resource.game_time = DayAndNightCycleManager.time
	game_data_resource.inventory_slots = InventoryManager.serialize_slots()
	game_data_resource.tool_slots = InventoryManager.serialize_tool_slots()
	game_data_resource.dialogue_states = GameDialogueManager.dialogue_states.duplicate()
	# 直接在序列化前加入需要保存的少量数据


func save_game() -> void:
	if !DirAccess.dir_exists_absolute(save_game_data_path):
		DirAccess.make_dir_absolute(save_game_data_path)
	
	var level_save_file_name: String = save_file_name % level_scene_name
	
	save_node_data()
	
	var result: int = ResourceSaver.save(game_data_resource, save_game_data_path + level_save_file_name)
	print("save result:", result)


func load_game() -> void:
	var level_save_file_name: String = save_file_name % level_scene_name
	var save_game_path: String = save_game_data_path + level_save_file_name
	
	if !FileAccess.file_exists(save_game_path):
		return
	
	game_data_resource = ResourceLoader.load(save_game_path)
	
	if game_data_resource == null:
		return
	
	var root_node: Window = get_tree().root
	
	for resource in game_data_resource.save_data_nodes:
		if resource is Resource:
			if resource is NodeDataResource:
				resource._load_data(root_node)
	
	print("Load time:",game_data_resource.game_time)
	DayAndNightCycleManager.time = game_data_resource.game_time

	InventoryManager.deserialize_slots(game_data_resource.inventory_slots)
	# 工具槽位单独恢复：覆盖 _init_tools() 的默认等级/伤害（旧存档无此字段时保留默认）
	InventoryManager.deserialize_tool_slots(game_data_resource.tool_slots)
	print("Load Inventory Slots: ", InventoryManager.SLOT_COUNT, " slots")
	InventoryManager.dump_slots()

	InventoryManager.inventory_changed.emit()
	# 手动更新库存UI

	if game_data_resource.dialogue_states:
		GameDialogueManager.dialogue_states = game_data_resource.dialogue_states.duplicate(true)
		print("Load Dialogue States:", GameDialogueManager.dialogue_states)
