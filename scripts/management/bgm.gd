extends AudioStreamPlayer

var tracks: Array = ["celestial", "red carpet wooden floor", "windless slopes"]

var previous_song: String = ""

func set_music() -> void:
	randomize()
	tracks.shuffle()
	random_song()


func random_song() -> void:
	var audiostream: AudioStream = load("res://assets/soundtrack/" + tracks.front() + ".mp3")
	previous_song = tracks.front()
	Interface.display_song(previous_song)
	tracks.remove(tracks.front())
	tracks.append(previous_song)
	set_stream(audiostream)
	play()
