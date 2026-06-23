extends PanelContainer

@onready var close_button: Button = $MarginContainer/VBoxContainer/Header/CloseButton
@onready var music_slider: HSlider = $MarginContainer/VBoxContainer/ScrollContainer/Content/MusicVolume/HSlider
@onready var music_percent_label: Label = $MarginContainer/VBoxContainer/ScrollContainer/Content/MusicVolume/PercentLabel
@onready var sfx_slider: HSlider = $MarginContainer/VBoxContainer/ScrollContainer/Content/SfxVolume/HSlider
@onready var sfx_percent_label: Label = $MarginContainer/VBoxContainer/ScrollContainer/Content/SfxVolume/PercentLabel
@onready var language_option: OptionButton = $MarginContainer/VBoxContainer/ScrollContainer/Content/Language/OptionButton
@onready var auto_torch_check: CheckBox = $MarginContainer/VBoxContainer/ScrollContainer/Content/AutoTorch/CheckBox

signal closed

func _ready() -> void:
	# 初始化滑块值
	music_slider.value = SettingsManager.get_value("audio", "music_volume", 1.0) * 100.0
	sfx_slider.value = SettingsManager.get_value("audio", "sfx_volume", 1.0) * 100.0

	_update_music_percent(music_slider.value)
	_update_sfx_percent(sfx_slider.value)

	# 初始化语言选项
	_setup_language_option()

	# 初始化火把自动开关
	auto_torch_check.button_pressed = SettingsManager.get_value("general", "auto_torch", true)

	# 连接信号
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	close_button.pressed.connect(_on_close_pressed)
	language_option.item_selected.connect(_on_language_selected)
	auto_torch_check.toggled.connect(_on_auto_torch_toggled)

func _setup_language_option() -> void:
	language_option.clear()
	language_option.add_item("English", 0)
	language_option.add_item("简体中文", 1)

	# 根据当前语言设置选中项
	var current_lang = TranslationServer.get_locale()
	if current_lang.begins_with("zh"):
		language_option.selected = 1
	else:
		language_option.selected = 0

func _on_music_slider_changed(value: float) -> void:
	SettingsManager.set_value("audio", "music_volume", value / 100.0)
	_update_music_percent(value)

func _on_sfx_slider_changed(value: float) -> void:
	SettingsManager.set_value("audio", "sfx_volume", value / 100.0)
	_update_sfx_percent(value)

func _update_music_percent(value: float) -> void:
	music_percent_label.text = "%d" % int(value)

func _update_sfx_percent(value: float) -> void:
	sfx_percent_label.text = "%d" % int(value)

func _on_language_selected(index: int) -> void:
	match index:
		0:
			SettingsManager.set_value("general", "language", "en")
		1:
			SettingsManager.set_value("general", "language", "zh_CN")

func _on_auto_torch_toggled(button_pressed: bool) -> void:
	SettingsManager.set_value("general", "auto_torch", button_pressed)

func _on_close_pressed() -> void:
	closed.emit()
	hide()
