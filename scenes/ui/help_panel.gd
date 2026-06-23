extends PanelContainer

@onready var close_button: Button = $MarginContainer/VBoxContainer/Header/CloseButton
@onready var tab_container: TabContainer = $MarginContainer/VBoxContainer/TabContainer
@onready var controls_text: RichTextLabel = $MarginContainer/VBoxContainer/TabContainer/Controls/RichTextLabel
@onready var farming_text: RichTextLabel = $MarginContainer/VBoxContainer/TabContainer/Farming/RichTextLabel
@onready var animals_text: RichTextLabel = $MarginContainer/VBoxContainer/TabContainer/Animals/RichTextLabel
@onready var about_text: RichTextLabel = $MarginContainer/VBoxContainer/TabContainer/About/RichTextLabel

signal closed

func _ready() -> void:
	close_button.pressed.connect(_on_close_pressed)
	_apply_translations()
	# 监听语言变化信号
	SettingsManager.language_changed.connect(_apply_translations)

func _apply_translations() -> void:
	# 设置选项卡标题
	tab_container.set_tab_title(0, tr("CONTROLS"))
	tab_container.set_tab_title(1, tr("FARMING"))
	tab_container.set_tab_title(2, tr("ANIMALS"))
	tab_container.set_tab_title(3, tr("ABOUT"))

	# 设置富文本内容
	controls_text.text = tr("HELP_CONTROLS")
	farming_text.text = tr("HELP_FARMING")
	animals_text.text = tr("HELP_ANIMALS")
	about_text.text = tr("HELP_ABOUT")

func _on_close_pressed() -> void:
	closed.emit()
	hide()
