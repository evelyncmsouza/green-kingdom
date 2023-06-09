extends KinematicBody2D

const EXPLOSION_FX = preload("res://scenes/effects/explosion_fx.tscn")

onready var animation: AnimationPlayer = get_node("Animation")
onready var sprite: Sprite = get_node("Sprite")

export(bool) var on_hit = false
export(bool) var can_fly = false

export(int) var walk_speed
export(int) var gravity
export(int) var health

export(float) var acceleration
export(float) var friction

export(PackedScene) var sfx

var player_ref: Object = null
var velocity: Vector2

func _physics_process(delta: float) -> void:
	move(delta)
	animate()
	change_direction()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	
func move(_delta: float) -> void:
	if player_ref != null and not can_fly:
		var direction: float = player_ref.global_position.x - global_position.x
		velocity.x = move_toward(velocity.x, walk_speed * direction, acceleration)
	elif not can_fly:
		velocity.x = move_toward(velocity.x, 0, friction)

func animate() -> void:
	pass

func change_direction() -> void:
	if velocity.x > 0:
		sprite.flip_h = true
	elif velocity.x < 0:
		sprite.flip_h = false

func on_detection_body_entered(body: Object) -> void:
	player_ref = body


func on_detection_area_body_exited(body: Object) -> void:
	player_ref = null


func on_damage_area_body_entered(_body: Object) -> void:
	pass
	
func instance_explosion(offset: Vector2) -> void:
	instance_sfx("res://assets/sfx/explosion_fx.wav", -20)
	var explosion: Object = EXPLOSION_FX.instance()
	get_tree().root.call_deferred("add_child", explosion)
	explosion.global_position = global_position + offset

func instance_sfx(current_sfx: String, sfx_volume: int) -> void:
	var sfx_scene: AudioStreamPlayer = sfx.instance()
	get_tree().root.call_deferred("add_child", sfx_scene)
	sfx_scene.set_stream(load(current_sfx))
	sfx_scene.volume_db = sfx_volume
	sfx_scene.play()
