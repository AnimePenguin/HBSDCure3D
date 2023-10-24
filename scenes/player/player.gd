extends CharacterBody3D
class_name Player

const WALK_SPEED := 3.5
const SPRINT_SPEED := 6
const FORWARD_INCREASE := 0.5
const JUMP := 4.5

const STAMINA_LOSS_RATE := 1.25
const STAMINA_GAIN_RATE := 0.75

const GRAVITY := 10

const BOB_FREQ := 2.5
const BOB_AMP := 0.04
var bob_time := 0.0

var look_speed: float =  SaveData.settings.sensitivity * 0.015

@export var weapon_scenes: Array[PackedScene]
var weapons := []
var weapon_index := 0

const AMMO_GAIN_AMOUNT := 20
var ammo := 100

var is_alive = true

func _ready() -> void:
	if weapon_scenes.is_empty():
		return
	
	weapons = weapon_scenes.map(func(weapon): return weapon.instantiate())
	$Head/Weapon.add_child(weapons[weapon_index])

func _process(_delta: float) -> void:
	if $StaminaHealDelay.is_stopped() and $StaminaTick.is_stopped():
		$Bars/Stamina.value += STAMINA_GAIN_RATE
		$StaminaTick.start()
	
	$Bars/Health.max_value = Modifiers.player.max_health
	$Bars/Stamina.max_value = Modifiers.player.max_stamina

func _physics_process(delta: float) -> void:
	var speed = WALK_SPEED
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	
	# Increase speed if you are going forward
	if input_dir.y == -1:
		speed += FORWARD_INCREASE
	
	if is_on_floor():
		if Input.is_action_just_pressed("jump") and is_alive:
			velocity.y = JUMP
	
		if Input.is_action_pressed("sprint") and $Bars/Stamina.value:
			speed = SPRINT_SPEED
			if $StaminaTick.is_stopped():
				$Bars/Stamina.value -= STAMINA_LOSS_RATE
				$StaminaTick.start()
				$StaminaHealDelay.start()
			
	else: # Apply gravity if not on floor
		velocity.y -= GRAVITY * delta
	
	var vel = $Head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)
	vel = vel.normalized() * speed

	if is_on_floor():
		if vel:
			velocity.x = vel.x
			velocity.z = vel.z
		else:
			velocity.x = lerp(velocity.x, 0., delta * 4)
			velocity.z = lerp(velocity.z, 0., delta * 4)
	else:
		velocity.x = lerp(velocity.x, vel.x, delta)
		velocity.z = lerp(velocity.z, vel.z, delta)
	
	bob_time += delta * velocity.length() * float(is_on_floor())
	$Head/First.transform.origin.y = sin(bob_time * BOB_FREQ) * BOB_AMP
	$Head/First.transform.origin.x = cos(bob_time * BOB_FREQ / 2) * BOB_AMP
	
	move_and_slide()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.mouse_mode:
		$Head.rotate_y(-event.relative.x * look_speed)
		
		$Head/First.rotate_x(-event.relative.y * look_speed)
		$Head/Weapon.rotate_x(-event.relative.y * look_speed)
		
		$Head/First.rotation.x = clamp($Head/First.rotation.x, -1.25, 1.25)
		$Head/Weapon.rotation.x = clamp($Head/Weapon.rotation.x, -1.25, 1.25)
		
	if event.is_action_pressed("change_weapon"):
		if not $AnimationPlayer.is_playing():
			$AnimationPlayer.play("swap_weapons")

func swap_gun():
	if weapons.is_empty():
		return
	
	$Head/Weapon.remove_child(weapons[weapon_index])
	weapon_index = (weapon_index + 1) % len(weapons)
	$Head/Weapon.add_child(weapons[weapon_index])

func gain_ammo():
	ammo += AMMO_GAIN_AMOUNT
	$PickupSound.play()
	
	for weapon in weapons:
		if weapon is WaterGun:
			weapon.update_ammo_label()

func take_damage(damage: int) -> void:
	$Bars/Health.value -= damage
	
	$AnimationPlayer.play("wobble_head")
	
	# If health is 0, Player Dies
	if not $Bars/Health.value and is_alive:
		is_alive = false
		
		weapons.map(func(weapon): weapon.disabled = true)
		$Head/Weapon.hide()
		
		create_tween().tween_property(self, "rotation:z", PI/2, 1)
		
		await get_tree().create_timer(1.5).timeout
		
		$GameOverScreen.show()
		$GameOverScreen/Stats.text %= SaveData.current_game.get_as_list()
		
		await get_tree().create_timer(4.5).timeout
		
		get_tree().reload_current_scene()

# Change the bar size if max health/stamina is changed
func _on_health_changed() -> void:
	$Bars/Health.custom_minimum_size.x = $Bars/Health.max_value * 2
	
func _on_stamina_changed() -> void:
	$Bars/Stamina.custom_minimum_size.x = $Bars/Stamina.max_value * 2
	
