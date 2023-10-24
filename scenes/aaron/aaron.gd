extends CharacterBody3D
class_name Aaron

const ammo_scene: PackedScene = preload("../player/water_gun/ammo/ammo.tscn")

const SPEED := 4
const GRAVITY := 10

const ATTACKING_RANGE_SQUARED := 2**2
const ATTACK_REACH_SQUARED := 2.5**2
const SEEK_DISTANCE_SQUARED := 32**2

const ATTACK_ANIMATIONS := ["Punch", "Kick", "TopDownAttack"]

enum AnimationAction {
	START_UP, IDLE, RUN, START_ATTACK, ATTACK, DIE
}

var anim_action := AnimationAction.START_UP

var health: int = Modifiers.aaron.health

var player: Player

func _ready() -> void:
	var world: Node3D = get_node("/root/World")
	
	if not world:
		set_physics_process(false)
		return
	
	player = world.get_node("Player")

func _process(_delta: float) -> void:
	match anim_action:
		AnimationAction.START_UP:
			anim_action = AnimationAction.IDLE
		
		AnimationAction.IDLE:
			$AnimationPlayer.play("Rumba")
			
		AnimationAction.RUN:
			$AnimationPlayer.play("Run")
			
		AnimationAction.START_ATTACK:
			var anim = Util.weighted_rand(ATTACK_ANIMATIONS, [4, 3, 1])
			$AnimationPlayer.play(anim)
			anim_action = AnimationAction.ATTACK
			
		AnimationAction.ATTACK:
			velocity /= SPEED * Modifiers.aaron.speed_multiplier
			velocity.y = -GRAVITY
			
			move_and_slide()
			
			if not $AnimationPlayer.is_playing():
				anim_action = AnimationAction.IDLE
		
		AnimationAction.DIE:
			collision_layer = 0b1000
			$AnimationPlayer.play("Die")
			set_process(false)

func _physics_process(_delta: float) -> void:
	look_at(Vector3(player.position.x, 0, player.position.z), Vector3.UP, true)
	
	if anim_action == AnimationAction.ATTACK or \
	   anim_action == AnimationAction.START_UP:
		return
	
	anim_action = AnimationAction.IDLE
	
	var distance_squared = position.distance_squared_to(player.position)
	
	if distance_squared > SEEK_DISTANCE_SQUARED:
		return
		
	elif distance_squared < ATTACKING_RANGE_SQUARED:
		anim_action = AnimationAction.START_ATTACK
		return
	
	# Movement
	$NavAgent.target_position = player.position
	
	if not $NavAgent.is_target_reachable():
		return
		
	var next_pos = $NavAgent.get_next_path_position()
	
	velocity = position.direction_to(next_pos)
	velocity *= SPEED * Modifiers.aaron.speed_multiplier
	
	velocity.y = 0
	if not is_on_floor():
		velocity.y -= GRAVITY
	
	anim_action = AnimationAction.RUN
	move_and_slide()

func take_damage(damage: int):
	health -= damage
	
	if health <= 0:
		set_physics_process(false)
		anim_action = AnimationAction.DIE

func do_damage(damage: int):
	if position.distance_squared_to(player.position) < ATTACK_REACH_SQUARED:
		player.take_damage(damage * Modifiers.aaron.damage_multiplier)
		$AudioPlayer3D.play()

func on_death():
	if randf() < Modifiers.aaron.ammo_drop_chance:
		var ammo = ammo_scene.instantiate() 
		ammo.position = global_position
		add_sibling(ammo)
	
	if randf() < 0.3:
		player.get_node("Bars/Health").value += 10
	
	SaveData.current_game.aarons_killed += 1
	
	var face_bone := $Armature/Skeleton3D/face
	face_bone.get_node("face").hide()
	face_bone.get_node("BloodLeak").emitting = true
	
	%model.mesh = %model.mesh.duplicate()
	
	var material = %model.mesh.surface_get_material(0).duplicate()
	
	%model.mesh.surface_set_material(0, material)
	material.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA
	
	var tween := create_tween()
	tween.tween_property(material, "albedo_color:a", 0, 2)
	await tween.finished
	
	queue_free()

func _on_step_detector_body_entered(_body: Node3D) -> void:
	if $StepDetector/StepCooldown.is_stopped():
		velocity.y = GRAVITY*3
		move_and_slide()
		$StepDetector/StepCooldown.start()
