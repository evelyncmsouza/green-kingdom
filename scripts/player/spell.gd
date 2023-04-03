extends Area2D

var direction: int = 1

export(int) var damage
export(int) var speed

export(PackedScene) var sfx

onready var animated_sprite: AnimatedSprite = get_node("AnimatedSprite")

func _ready() -> void:
	instance_sfx("res://assets/sfx/ice_spell.wav", -20)
	animated_sprite.play("Start")
	verify_direction()
	
func verify_direction() -> void:
	if direction > 0:
		animated_sprite.flip_h = false
	elif direction < 0:
		animated_sprite.flip_h = true
		
func _physics_process(_delta: float) -> void:
	translate(Vector2(speed * direction, 0))

func on_body_entered(body) -> void:
	if body.is_in_group("Enemy"):
		body.update_health(damage)
		
	set_physics_process(false)
	animated_sprite.play("Hit")

func on_area_entered(area) -> void:
	if area.is_in_group("Projectile"):
		area.update_health(damage)
		set_physics_process(false)
		animated_sprite.play("Hit")

func on_animation_finished() -> void:
	match animated_sprite.animation:
		"Start":
			animated_sprite.play("Loop")
			
		"Hit":
			queue_free()

func on_screen_exited() -> void:
	queue_free()

func instance_sfx(current_sfx: String, sfx_volume: int) -> void:
	var sfx_scene: AudioStreamPlayer = sfx.instance()
	get_tree().root.call_deferred("add_child", sfx_scene)
	sfx_scene.set_stream(load(current_sfx))
	sfx_scene.volume_db = sfx_volume
	sfx_scene.play()
