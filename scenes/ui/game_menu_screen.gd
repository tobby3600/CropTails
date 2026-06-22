extends CanvasLayer

@onready var save_game_button: Button = $MarginContainer/VBoxContainer/SaveGameButton
@onready var resume_game_button: Button = $MarginContainer/VBoxContainer/ResumeGameButton
@onready var settings_panel: PanelContainer = $SettingsPanel

func _ready() -> void:
	save_game_button.disabled = !SaveGameManager.allow_save_game
	save_game_button.focus_mode = Control.FOCUS_ALL if SaveGameManager.allow_save_game else Control.FOCUS_NONE

	resume_game_button.disabled = !SaveGameManager.allow_save_game
	resume_game_button.focus_mode = Control.FOCUS_ALL if SaveGameManager.allow_save_game else Control.FOCUS_NONE

	settings_panel.closed.connect(_on_settings_closed)

func _on_start_game_button_pressed() -> void:
	GameManager.game_menu_screen_instance = null
	get_tree().paused = false
	call_deferred("free")
	GameManager.start_game()

func _on_save_game_button_pressed() -> void:
	SaveGameManager.save_game()

func _on_resume_game_button_pressed() -> void:
	GameManager.resume_game()

func _on_exit_game_button_pressed() -> void:
	GameManager.exit_game()

func _on_settings_button_pressed() -> void:
	settings_panel.show()

func _on_settings_closed() -> void:
	settings_panel.hide()
