extends Node

signal settings_changed(category: String, key: String, value: Variant)
signal language_changed

const SETTINGS_PATH := "user://settings.ini"

var settings := {
	"audio": {
		"music_volume": 1.0,
		"sfx_volume": 1.0,
	},
	"general": {
		"language": "en",
		"auto_torch": true,
	}
}

func _ready() -> void:
	load_settings()
	apply_all()

func get_value(category: String, key: String, default = null):
	return settings.get(category, {}).get(key, default)

func set_value(category: String, key: String, value) -> void:
	if not settings.has(category):
		settings[category] = {}
	settings[category][key] = value
	apply_setting(category, key, value)
	settings_changed.emit(category, key, value)
	save_settings()

func apply_setting(category: String, key: String, value) -> void:
	match category:
		"audio":
			match key:
				"music_volume":
					set_bus_volume("Music", value)
				"sfx_volume":
					set_bus_volume("SFX", value)
		"general":
			match key:
				"language":
					TranslationServer.set_locale(value)
					language_changed.emit()

func apply_all() -> void:
	for category in settings:
		for key in settings[category]:
			apply_setting(category, key, settings[category][key])

func set_bus_volume(bus_name: String, linear: float) -> void:
	var db := linear_to_db(clamp(linear, 0.001, 1.0))
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index(bus_name), db)

func save_settings() -> void:
	var config := ConfigFile.new()
	for category in settings:
		for key in settings[category]:
			config.set_value(category, key, settings[category][key])
	config.save(SETTINGS_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SETTINGS_PATH) == OK:
		for category in settings:
			if config.has_section(category):
				for key in settings[category]:
					if config.has_section_key(category, key):
						settings[category][key] = config.get_value(category, key)
