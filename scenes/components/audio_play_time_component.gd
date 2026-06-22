extends Timer

@export var audio_stream_player_2D : AudioStreamPlayer2D


func _on_timeout() -> void:
	if audio_stream_player_2D == null:
		push_error("Found null AudioStreamPlayer in AudioPlayTimeComponent")
		return
	audio_stream_player_2D.play()
