extends AudioStreamPlayer

func on_sfx_finished():
	queue_free()
