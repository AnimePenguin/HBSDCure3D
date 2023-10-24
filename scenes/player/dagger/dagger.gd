extends Area3D

var disabled = false

var anim_index = 0

func _unhandled_input(event: InputEvent) -> void:
	if $AnimationPlayer.is_playing() or disabled:
		return
	
	# Fixes weird bug where the animation doesn't start on .play()
	$AnimationPlayer.seek(0)
	
	if event.is_action_pressed("left_click"):
		# Play swing animations alternatively
		$AnimationPlayer.play(["swing1", "swing2"][anim_index % 2])
		anim_index += 1
	elif event.is_action_pressed("right_click"):
		$AnimationPlayer.play("swing_heavy")

func hit_enemy(damage):
	for body in get_overlapping_bodies():
		if body is Aaron:
			body.take_damage(damage * Modifiers.player.dagger_damage_multiplier)
			$Mesh/Blood.emitting = true
