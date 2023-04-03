extends Node2D

onready var player: KinematicBody2D = get_node("JungleGuy")

func _ready() -> void:
	var _camera = player.connect("change_main_camera", self, "change_camera")
	
func change_camera(camera: Camera2D, camera_position: Vector2) -> void:
	var new_camera: Camera2D = Camera2D.new()
	add_child(camera)
	add_child(new_camera)
	new_camera.current = true
	new_camera.limit_bottom = 0
	new_camera.limit_top = 0
	new_camera.position = camera_position
