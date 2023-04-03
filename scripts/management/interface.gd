extends CanvasLayer

onready var song_texture: TextureRect = get_node("SongText")
onready var animation: AnimationPlayer = get_node("Animation")
onready var display_song_anim: AnimationPlayer = get_node("SongText/Animation")

func fade_in() -> void:
	animation.play("fade_in")
	
func display_song(song: String) -> void:
	song_texture.texture = load("res://assets/interface/text/" + song + ".png")
	display_song_anim.play("display_song")
	
func change_level() -> void:
	var _change_scene = get_tree().change_scene("res://scenes/management/world.tscn")
	animation.play("fade_out")
