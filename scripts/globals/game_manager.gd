extends Node

var game_menu_screen = preload("res://scenes/ui/game_menu_screen.tscn")
var game_menu_screen_instance: CanvasLayer = null

var backpack_screen = preload("res://scenes/ui/backpack_screen/backpack_screen.tscn")
var backpack_screen_instance: CanvasLayer = null

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		if game_menu_screen_instance:
			# 检查设置面板或帮助面板是否打开
			var settings_panel = game_menu_screen_instance.get_node_or_null("SettingsPanel")
			var help_panel = game_menu_screen_instance.get_node_or_null("HelpPanel")

			if settings_panel and settings_panel.visible:
				settings_panel.hide()
			elif help_panel and help_panel.visible:
				help_panel.hide()
			else:
				resume_game()
		else:
			show_game_menu_screen()

	if event.is_action_pressed("open_inventory"):
		if game_menu_screen_instance:
			return  # 游戏菜单打开时不处理
		if backpack_screen_instance:
			close_backpack()
		else:
			open_backpack()

func start_game() -> void:
	SceneManager.load_main_scene_container()
	SceneManager.load_level("Level1")
	SaveGameManager.load_game()
	SaveGameManager.allow_save_game = true

func exit_game() -> void:
	get_tree().quit()

func show_game_menu_screen() -> void:
	game_menu_screen_instance = game_menu_screen.instantiate()
	get_tree().root.add_child(game_menu_screen_instance)
	get_tree().paused = true

func resume_game() -> void:
	if game_menu_screen_instance:
		game_menu_screen_instance.queue_free()
		game_menu_screen_instance = null
	get_tree().paused = false


func open_backpack() -> void:
	if backpack_screen_instance:
		return
	backpack_screen_instance = backpack_screen.instantiate()
	get_tree().root.add_child(backpack_screen_instance)


func close_backpack() -> void:
	if backpack_screen_instance:
		backpack_screen_instance.queue_free()
		backpack_screen_instance = null
