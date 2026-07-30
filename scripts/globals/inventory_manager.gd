extends Node

# === 槽位范围常量 ===
const TOOL_SLOT_START := 0
const TOOL_SLOT_END := 8     # 工具栏：槽位 0-8（9个工具槽位）
const ITEM_SLOT_START := 9
const ITEM_SLOT_END := 31    # 物品栏：槽位 9-31（23个物品槽位）
const SLOT_COUNT := 32

# === 槽位数组 ===
var slots: Array[InventorySlot] = []

# === 物品类型注册表（从 data/items.json 加载） ===
var item_registry: Dictionary = {}
var ITEMS_JSON_PATH := "res://data/items.json"

# === 信号 ===
signal inventory_changed
signal slot_changed(index: int)

# === 工具枚举 → 槽位索引映射 ===
var _tool_slot_map: Dictionary = {
	DataTypes.Tools.Axewood:     0,
	DataTypes.Tools.TillGround:  1,
	DataTypes.Tools.WaterCrops:  2,
	DataTypes.Tools.PlantCorn:   3,
	DataTypes.Tools.PlantTomato: 4,
}

# === 工具枚举 → item_id（与 items.json 的 key 对应） ===
var _tool_item_map: Dictionary = {
	DataTypes.Tools.Axewood:     "axe",
	DataTypes.Tools.TillGround:  "tilling",
	DataTypes.Tools.WaterCrops:  "watering_can",
	DataTypes.Tools.PlantCorn:   "corn_seeds",
	DataTypes.Tools.PlantTomato: "tomato_seeds",
}


func _ready() -> void:
	# 初始化所有槽位为 null
	slots.resize(SLOT_COUNT)
	for i in SLOT_COUNT:
		slots[i] = null

	# 从 JSON 加载物品注册表
	_load_item_registry()

	# 将 5 个工具按顺序放入工具槽位 0-4（槽位 5-8 为预留空位）
	_init_tools()


func _load_item_registry() -> void:
	var file = FileAccess.open(ITEMS_JSON_PATH, FileAccess.READ)
	if file == null:
		push_error("InventoryManager: 无法打开物品注册表: ", ITEMS_JSON_PATH)
		return

	var json_text = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_text)
	if error != OK:
		push_error("InventoryManager: JSON 解析失败: ", json.get_error_message())
		return

	item_registry = json.data

	# 将 icon_region 数组转为 Rect2
	for item_id in item_registry:
		var info = item_registry[item_id]
		if info.has("icon_region") and info["icon_region"] is Array:
			var r = info["icon_region"]
			if r.size() == 4:
				info["icon_region"] = Rect2(r[0], r[1], r[2], r[3])

	print("InventoryManager: 已加载 ", item_registry.size(), " 种物品")


# ============================================================
#  槽位读写
# ============================================================

func get_slot(index: int) -> InventorySlot:
	if index < 0 or index >= SLOT_COUNT:
		push_error("InventoryManager: 槽位索引越界: ", index)
		return null
	return slots[index]


func set_slot(index: int, slot: InventorySlot) -> void:
	if index < 0 or index >= SLOT_COUNT:
		push_error("InventoryManager: 槽位索引越界: ", index)
		return
	slots[index] = slot
	slot_changed.emit(index)
	inventory_changed.emit()


# ============================================================
#  物品栏操作（槽位 5-19）
# ============================================================

## 在物品栏范围内添加物品，自动找空槽或合并已有槽位
func add_item(item_id: String, count: int = 1, custom_data: Dictionary = {}) -> bool:
	var max_stack = get_max_stack(item_id)

	# 先尝试合并到已有槽位
	for i in range(ITEM_SLOT_START, ITEM_SLOT_END + 1):
		var slot = slots[i]
		if slot and slot.item_id == item_id and slot.count < max_stack:
			var space = max_stack - slot.count
			var to_add = mini(count, space)
			slot.count += to_add
			count -= to_add
			slot_changed.emit(i)
			if count <= 0:
				inventory_changed.emit()
				return true

	# 剩余数量放入空槽位
	while count > 0:
		var empty_index = _find_empty_slot(ITEM_SLOT_START, ITEM_SLOT_END)
		if empty_index == -1:
			push_warning("InventoryManager: 物品栏已满，无法添加: ", item_id)
			inventory_changed.emit()
			return false
		var to_add = mini(count, max_stack)
		slots[empty_index] = InventorySlot.new(item_id, to_add, custom_data.duplicate())
		count -= to_add
		slot_changed.emit(empty_index)

	inventory_changed.emit()
	return true


## 从物品栏移除指定数量物品
func remove_item(item_id: String, count: int = 1) -> bool:
	var remaining = count
	# 从后往前移除，保持前面槽位紧凑
	for i in range(ITEM_SLOT_END, ITEM_SLOT_START - 1, -1):
		var slot = slots[i]
		if slot and slot.item_id == item_id:
			var to_remove = mini(remaining, slot.count)
			slot.count -= to_remove
			remaining -= to_remove
			if slot.count <= 0:
				slots[i] = null
			slot_changed.emit(i)
			if remaining <= 0:
				inventory_changed.emit()
				return true

	if remaining > 0:
		push_warning("InventoryManager: 物品数量不足，无法移除: ", item_id, " 缺少: ", remaining)
	inventory_changed.emit()
	return false


# ============================================================
#  查询方法
# ============================================================

## 查找第一个包含指定物品的槽位索引（优先物品栏）
func find_first_slot(item_id: String) -> int:
	for i in range(ITEM_SLOT_START, ITEM_SLOT_END + 1):
		if slots[i] and slots[i].item_id == item_id:
			return i
	# 也检查工具栏
	for i in range(TOOL_SLOT_START, TOOL_SLOT_END + 1):
		if slots[i] and slots[i].item_id == item_id:
			return i
	return -1


## 获取指定物品的总数量（跨所有槽位求和）
func get_item_count(item_id: String) -> int:
	var total := 0
	for slot in slots:
		if slot and slot.item_id == item_id:
			total += slot.count
	return total


## 检查是否有足够数量的物品
func has_item(item_id: String, count: int = 1) -> bool:
	return get_item_count(item_id) >= count


## 获取最大堆叠数
func get_max_stack(item_id: String) -> int:
	return item_registry.get(item_id, {}).get("max_stack", 99)


## 注册物品类型
func register_item(item_id: String, properties: Dictionary) -> void:
	item_registry[item_id] = properties


## 获取物品本地化显示名
func get_display_name(item_id: String) -> String:
	var result = _get_localized(item_id, "display_name")
	return result if result != "" else item_id


## 获取物品本地化描述
func get_description(item_id: String) -> String:
	return _get_localized(item_id, "description")


func _get_localized(item_id: String, key: String) -> String:
	var info = item_registry.get(item_id)
	if info == null:
		return ""
	var locale = TranslationServer.get_locale()
	if locale == "zh_CN":
		var localized_key = key + "_zh_CN"
		if info.has(localized_key) and info[localized_key] is String and info[localized_key] != "":
			return info[localized_key]
	return info.get(key, "")


## 获取物品图标 Texture（从注册表动态生成 AtlasTexture）
func get_item_icon(item_id: String) -> Texture2D:
	var info = item_registry.get(item_id)
	if info == null:
		return null

	# 完整纹理
	if info.has("icon_texture"):
		return load(info["icon_texture"])

	# Atlas 裁剪
	if info.has("icon_atlas") and info.has("icon_region"):
		var atlas_tex = AtlasTexture.new()
		atlas_tex.atlas = load(info["icon_atlas"])
		atlas_tex.region = info["icon_region"]
		return atlas_tex

	return null


## 获取物品掉落物场景（从注册表加载 drop_scene 路径）
func get_item_drop_scene(item_id: String) -> PackedScene:
	var info = item_registry.get(item_id)
	if info == null:
		return null
	var path = info.get("drop_scene", "")
	if path is String and path != "":
		return load(path)
	return null


# ============================================================
#  工具栏操作（槽位 0-4）
# ============================================================

## 根据 DataTypes.Tools 枚举获取对应工具槽位
func get_tool_slot(tool: DataTypes.Tools) -> InventorySlot:
	var index = _tool_slot_map.get(tool, -1)
	if index == -1:
		return null
	return slots[index]


## 初始化/设置工具到固定槽位
func set_tool(tool: DataTypes.Tools, item_id: String, custom_data: Dictionary = {}) -> void:
	var index = _tool_slot_map.get(tool, -1)
	if index == -1:
		push_error("InventoryManager: 未知工具枚举: ", tool)
		return
	slots[index] = InventorySlot.new(item_id, 1, custom_data)
	slot_changed.emit(index)
	inventory_changed.emit()


## 根据 DataTypes.Tools 枚举获取对应的槽位索引
func get_tool_slot_index(tool: DataTypes.Tools) -> int:
	return _tool_slot_map.get(tool, -1)


## 启动时初始化工具栏：按 _tool_slot_map 的顺序把工具放入固定槽位
## 默认携带 level/damage 自定义属性，供后续工具升级功能使用
func _init_tools() -> void:
	for tool in _tool_item_map:
		var item_id: String = _tool_item_map[tool]
		if not item_registry.has(item_id):
			push_error("InventoryManager: 工具物品未在 items.json 中注册: ", item_id)
			continue
		set_tool(tool, item_id, {"level": 1, "damage": 1})


# ============================================================
#  序列化（存档用）
# ============================================================

func serialize_slots() -> Array:
	var result := []
	for i in SLOT_COUNT:
		if slots[i] and not slots[i].is_empty():
			result.append(slots[i].to_dict())
		else:
			result.append(null)
	return result


func deserialize_slots(data: Array) -> void:
	slots.resize(SLOT_COUNT)
	for i in SLOT_COUNT:
		# 工具槽位（0-8）由 deserialize_tool_slots() 单独恢复，此处跳过
		if i >= TOOL_SLOT_START and i <= TOOL_SLOT_END:
			continue
		if i < data.size() and data[i] != null:
			slots[i] = InventorySlot.from_dict(data[i])
		else:
			slots[i] = null


## 序列化工具槽位（0-8）— 单独存储，custom_data 包含等级（level）和伤害（damage）等升级信息
func serialize_tool_slots() -> Array:
	var result := []
	for i in range(TOOL_SLOT_START, TOOL_SLOT_END + 1):
		if slots[i] and not slots[i].is_empty():
			result.append(slots[i].to_dict())
		else:
			result.append(null)
	return result


## 反序列化工具槽位（0-8）— 覆盖 _init_tools() 写入的默认工具数据
## 存档无工具数据时（旧存档）保留默认等级和伤害
func deserialize_tool_slots(data: Array) -> void:
	if data.is_empty():
		return
	for i in range(TOOL_SLOT_START, TOOL_SLOT_END + 1):
		var data_index := i - TOOL_SLOT_START
		if data_index < data.size() and data[data_index] != null:
			slots[i] = InventorySlot.from_dict(data[data_index])
		else:
			slots[i] = null


# ============================================================
#  内部辅助
# ============================================================

func dump_slots() -> void:
	print("=== InventoryManager 槽位数据 (共 %d 槽位) ===" % SLOT_COUNT)
	for i in SLOT_COUNT:
		var slot = slots[i]
		if slot and not slot.is_empty():
			print("  槽位 %2d: item_id=%-14s count=%-3d custom_data=%s" % [i, slot.item_id, slot.count, slot.custom_data])
		else:
			print("  槽位 %2d: (空)" % i)
	print("===============================================")


func _find_empty_slot(start: int, end: int) -> int:
	for i in range(start, end + 1):
		if slots[i] == null or slots[i].is_empty():
			return i
	return -1
