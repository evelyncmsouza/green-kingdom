extends "res://scripts/enemies/enemy_template.gd"

var direction: Vector2

export(int) var damage

export(bool) var ceiling_out = false

func move(delta: float) -> void:
	if player_ref != null:
		direction = (player_ref.global_position - global_position).normalized()
		velocity = velocity.move_toward(direction * walk_speed, acceleration * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	
func animate() -> void:
	if player_ref != null and not ceiling_out:
		animation.play("Ceiling_Out")
	elif not on_hit and player_ref != null and ceiling_out:
		animation.play("Flying")
	elif on_hit and ceiling_out:
		set_physics_process(false)
		animation.play("Hit")

func update_health(amount: int) -> void:
	health -= amount
	on_hit = true
	if health <= 0:
		instance_explosion(Vector2(0, -20))
		queue_free()
	else:
		instance_sfx("res://assets/sfx/hit.mp3", -10)
		
func on_damage_area_body_entered(body: Object) -> void:
	body.update_health(damage, global_position)

func on_animation_finished(anim_name):
	if anim_name == "Ceiling_Out":
		animation.play("Flying")
