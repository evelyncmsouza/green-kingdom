extends "res://scripts/enemies/enemy_template.gd"

onready var bullet_spawn_pos: Position2D = get_node("BulletSpawnPosition")

export(PackedScene) var bullet
export(int) var direction = -1
export(int) var damage

func animate() -> void:
	if not on_hit and player_ref != null:
		animation.play("Attack")
	elif not on_hit:
		animation.play("Idle")
	else:
		animation.play("Hit")
		
func change_direction() -> void:
	if player_ref != null:
		var distance_between: int = (global_position.x - player_ref.global_position.x)
		direction = sign(distance_between)
		var _flip_h = sprite.set_flip_h(false) if direction > 0 else sprite.set_flip_h(true)
		var _pos = bullet_spawn_pos.set_position(Vector2(-20, -2)) if direction > 0 else bullet_spawn_pos.set_position(Vector2(20, -2))
		
func update_health(amount: int) -> void:
	health -= amount
	on_hit = true
	if health <= 0:
		instance_explosion(Vector2(0, -10))
		queue_free()
	else:
		instance_sfx("res://assets/sfx/hit.mp3", -10)
		
func spawn_bullet() -> void:
	var projectile: Object = bullet.instance()
	#get_tree().root.call_deferred("add_child", projectile)
	get_parent().add_child(projectile)
	projectile.global_position = bullet_spawn_pos.global_position
	projectile.direction = -direction
	
func on_damage_area_body_entered(body: Object) -> void:
	body.update_health(damage, global_position)
