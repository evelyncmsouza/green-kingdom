extends Control

onready var v_box: VBoxContainer = get_node("VBox")

export(PackedScene) var sfx

func _ready() -> void:
	for button in v_box.get_children():
		button.connect("pressed", self, "on_button_pressed", [button])
		button.connect("mouse_entered", self, "on_mouse_entered", [button])
		button.connect("mouse_exited", self, "on_mouse_exited", [button])
		
func on_button_pressed(button: Button) -> void:
	button.modulate.a - 0.2
	match button.name:
		"Start":
			instance_sfx("res://assets/sfx/button_click.wav", 0)
			Interface.fade_in()
			
		"Quit":
			instance_sfx("res://assets/sfx/button_click.wav", 0)
			yield(get_tree().create_timer(0.2), "timeout")
			get_tree().quit()
			
func on_mouse_entered(button: Button) -> void:
	button.modulate.a = 0.6
	
func on_mouse_exited(button: Button) -> void:
	button.modulate.a = 1.0

func instance_sfx(current_sfx: String, sfx_volume: int) -> void:
	var sfx_scene: AudioStreamPlayer = sfx.instance()
	get_tree().root.call_deferred("add_child", sfx_scene)
	sfx_scene.set_stream(load(current_sfx))
	sfx_scene.volume_db = sfx_volume
	sfx_scene.play()

func on_animation_finished(anim_name: String) -> void:
	if anim_name == "initian_screen_animation":
		Bgm.set_music()
