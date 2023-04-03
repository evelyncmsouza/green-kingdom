extends KinematicBody2D

signal change_main_camera

const EXPLOSION = preload("res://scenes/effects/explosion_fx.tscn")
const SMOKEFX = preload("res://scenes/effects/smoke_fx.tscn")
const DASHFX = preload("res://scenes/effects/dash_fx.tscn")
const SPELL = preload("res://scenes/player/spell.tscn")

var velocity: Vector2
var knockback: Vector2
var dash_direction: Vector2
var enemy_position: Vector2

var jump_count: int = 0

var can_dash: bool = false
var is_dashing: bool = false
var can_attack: bool = true

export(int) var health
export(int) var walk_speed
export(int) var dash_speed
export(int) var knockback_speed
export(int) var gravity
export(int) var jump_speed
export(int) var idle_threshold

export(float) var attack_cooldown
export(float) var acceleration
export(float) var dash_length
export(float) var friction

export(bool) var on_hit

export(PackedScene) var sfx

onready var animated_sprite: AnimatedSprite = get_node("AnimatedSprite")
onready var spell_spawner: Position2D = get_node("SpellSpawner")
onready var animation: AnimationPlayer = get_node("Animation")
onready var attack_timer: Timer = get_node("AttackTimer")
onready var dash_timer: Timer = get_node("DashTimer")
onready var camera: Camera2D = get_node("Camera")

func _ready() -> void:
	attack_timer.set_wait_time(attack_cooldown)
	
func _physics_process(delta: float) -> void:
	move()
	attack()
	handle_dash()
	animate()
	velocity.y += gravity * delta
	velocity = move_and_slide(velocity, Vector2.UP)
	jump()
	
func move() -> void:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	
	if on_hit:
		var direction: Vector2 = (global_position - enemy_position).normalized()
		knockback.x = (direction.x * knockback_speed) * 2
		knockback.y = -knockback_speed/2
		knockback = move_and_slide(knockback)
		
	if input_vector.x != 0:
		velocity.x = lerp(velocity.x, walk_speed * input_vector.x, acceleration)
	else:
		velocity.x = lerp(velocity.x, 0, friction)
		
func attack() -> void:
	if Input.is_action_just_pressed("Attack") and can_attack:
		camera.shake(5, 0.2)
		var spell: Object = SPELL.instance()
		spell.global_position = spell_spawner.global_position
		spell.direction = sign(spell_spawner.position.x)
		get_tree().root.call_deferred("add_child", spell)
		attack_timer.start()
		can_attack = false
		
func handle_dash() -> void:
	if Input.is_action_just_pressed("Dash") and can_dash and not is_on_floor():
		instance_sfx("res://assets/sfx/dash_sfx.wav", -20)
		is_dashing = true
		can_dash = false
		dash_direction = dash()
		dash_timer.start(dash_length)
		
	if is_dashing:
		spawn_dash_effect()
		dash_direction = move_and_slide(dash_direction)
		
		if is_on_floor() or is_on_wall():
			is_dashing = false
		
func dash() -> Vector2:
	var input_vector: Vector2 = Vector2.ZERO
	input_vector.x = Input.get_action_strength("Right") - Input.get_action_strength("Left")
	input_vector.y = Input.get_action_strength("Down") - Input.get_action_strength("Up")
	input_vector = input_vector.clamped(1)
	if input_vector == Vector2.ZERO:
		if animated_sprite.flip_h:
			input_vector.x = -1
		else:
			input_vector.x = 1
			
	return input_vector * dash_speed

func jump() -> void:
	if is_on_floor() and jump_count != 0:
		can_dash = false
		camera.shake(5, 0.2)
		spawn_dust_effect()
		jump_count = 0
	
	if Input.is_action_just_pressed("Jump") and jump_count < 2:
		instance_sfx("res://assets/sfx/jump_sfx.wav", -40)
		jump_count += 1
		velocity.y = -jump_speed
		can_dash = true

func animate() -> void:
	change_direction()
	if velocity.y != 0:
		jump_animation()
	else:
		move_animation()
	
func change_direction() -> void:
	if velocity.x > 0:
		spell_spawner.position.x = 18
		animated_sprite.flip_h = false
	elif velocity.x < 0:
		spell_spawner.position.x = -18
		animated_sprite.flip_h = true
		
func jump_animation() -> void:
	if velocity.y > 0:
		animated_sprite.play("Fall")
	elif velocity.y < 0:
		animated_sprite.play("Jump")
		
func move_animation() -> void:
	if abs(velocity.x) > idle_threshold:
		animated_sprite.play("Run")
	else:
		animated_sprite.play("Idle")

func spawn_dust_effect() -> void:
	var dust: Object = SMOKEFX.instance()
	get_tree().root.call_deferred("add_child", dust)
	dust.global_position = global_position + Vector2(0, 1)

func spawn_dash_effect() -> void:
	var dash: Object = DASHFX.instance()
	dash.texture = animated_sprite.frames.get_frame(animated_sprite.animation, animated_sprite.frame)
	dash.global_position = global_position
	dash.flip_h = animated_sprite.flip_h
	get_tree().root.call_deferred("add_child", dash)
	
func on_dash_timeout() -> void:
	is_dashing = false

func on_attack_timeout() -> void:
	can_attack = true

func update_health(damage_amount: int, enemy_global_position: Vector2) -> void:
	animation.play("Hit")
	enemy_position = enemy_global_position
	on_hit = true
	health -= damage_amount
	if health <= 0:
		kill()
	else:
		instance_sfx("res://assets/sfx/hit.mp3", -10)
		camera.shake(10, 0.3)
		
func kill() -> void:
	remove_child(camera)
	emit_signal("change_main_camera", camera, global_position)
	instance_explosion()
	queue_free()
	
func instance_explosion() -> void:
	instance_sfx("res://assets/sfx/explosion_fx.wav", -20)
	var explosion: Object = EXPLOSION.instance()
	explosion.global_position = global_position + Vector2(0, -10)
	get_tree().root.call_deferred("add_child", explosion)


func on_screen_exited() -> void:
	Interface.fade_in()

func instance_sfx(current_sfx: String, sfx_volume: int) -> void:
	var sfx_scene: AudioStreamPlayer = sfx.instance()
	get_tree().root.call_deferred("add_child", sfx_scene)
	sfx_scene.set_stream(load(current_sfx))
	sfx_scene.volume_db = sfx_volume
	sfx_scene.play()
