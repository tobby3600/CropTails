extends Node

var game_menu_screen = preload("res://scenes/ui/game_menu_screen.tscn")
var game_menu_screen_instance: CanvasLayer = null

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("game_menu"):
		if game_menu_screen_instance:
			resume_game()
		else:
			show_game_menu_screen()

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
	
