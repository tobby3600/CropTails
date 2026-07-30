extends CanvasLayer

# 按钮悬浮动画参数
const HOVER_SCALE := Vector2(1.12, 1.12) # 悬浮时放大倍数
const HOVER_TILT_DEG := 3.0 # 悬浮时倾斜角度（度）
const HOVER_DURATION := 0.15 # 动画时长（秒）

@onready var save_game_button: Button = $MarginContainer/VBoxContainer/SaveGameButton
@onready var resume_game_button: Button = $MarginContainer/VBoxContainer/ResumeGameButton
@onready var settings_panel: PanelContainer = $SettingsPanel
@onready var help_panel: PanelContainer = $HelpPanel

var _hover_tweens: Dictionary = {} # Button -> Tween，快速移入移出时先杀掉旧动画

func _ready() -> void:
	save_game_button.disabled = !SaveGameManager.allow_save_game
	save_game_button.focus_mode = Control.FOCUS_ALL if SaveGameManager.allow_save_game else Control.FOCUS_NONE

	resume_game_button.disabled = !SaveGameManager.allow_save_game
	resume_game_button.focus_mode = Control.FOCUS_ALL if SaveGameManager.allow_save_game else Control.FOCUS_NONE

	settings_panel.closed.connect(_on_settings_closed)
	help_panel.closed.connect(_on_help_closed)

	_setup_button_hover_animations()

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

func _on_help_button_pressed() -> void:
	help_panel.show()

func _on_help_closed() -> void:
	help_panel.hide()

# ============================================================
#  按钮悬浮动画（Tween：倾斜 + 放大）
# ============================================================

func _setup_button_hover_animations() -> void:
	# 遍历菜单按钮列（Start/Save/Resume/Exit）和右上角按钮列（Help/Settings）
	for container: Container in [$MarginContainer/VBoxContainer, $MarginContainer2/VBoxContainer]:
		for button in container.get_children():
			if button is Button:
				button.resized.connect(_on_button_resized.bind(button))
				button.mouse_entered.connect(_on_button_mouse_entered.bind(button))
				button.mouse_exited.connect(_on_button_mouse_exited.bind(button))


# Control 默认以左上角为缩放/旋转中心，布局完成后把中心点移到按钮中央
func _on_button_resized(button: Button) -> void:
	button.pivot_offset = button.size / 2


func _on_button_mouse_entered(button: Button) -> void:
	if button.disabled:
		return
	# 随机向左或向右倾斜，增加灵动感
	var tilt := deg_to_rad(HOVER_TILT_DEG) * (1.0 if randf() > 0.5 else -1.0)
	_tween_button_hover(button, HOVER_SCALE, tilt)


func _on_button_mouse_exited(button: Button) -> void:
	_tween_button_hover(button, Vector2.ONE, 0.0)


func _tween_button_hover(button: Button, target_scale: Vector2, target_rotation: float) -> void:
	# 杀掉旧动画，防止快速连续悬浮时动画重叠/闪烁（同 rock.gd 模式）
	var old_tween: Tween = _hover_tweens.get(button)
	if old_tween and old_tween.is_valid():
		old_tween.kill()

	# TWEEN_PAUSE_PROCESS：Esc 菜单在游戏暂停时显示，动画需照常播放
	# set_parallel(true)：缩放和旋转同时进行
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS).set_parallel(true)
	tween.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tween.tween_property(button, "scale", target_scale, HOVER_DURATION)
	tween.tween_property(button, "rotation", target_rotation, HOVER_DURATION)
	_hover_tweens[button] = tween
