extends Area3D

const SPEED := 40
const DOWNWARD_ROTATION := 0.5

const DAMAGE := 12

func _physics_process(delta: float) -> void:
	position += transform.basis * Vector3(SPEED, 0, 0) * delta
	
	rotate_z(-DOWNWARD_ROTATION * delta)
	rotation.z = min(rotation.z, PI/2)

func _on_body_entered(body: Node3D) -> void:
	if body is Aaron:
		body.take_damage(DAMAGE * Modifiers.player.bullet_damage_multiplier)
	
	$WaterSplash.emitting = true
	$Mesh.hide()
	set_physics_process(false)
	
	get_tree().create_timer(0.25).timeout.connect(queue_free)

func _on_decay_timer_timeout() -> void:
	queue_free()

