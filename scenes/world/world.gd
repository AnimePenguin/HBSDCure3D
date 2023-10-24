extends Node3D

const aaron_scene: PackedScene = preload("res://scenes/aaron/aaron.tscn")

func _ready() -> void:
	randomize()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	# Reset Modifiers
	Modifiers.aaron = Modifiers.DEFAULT_AARON.duplicate()
	Modifiers.player = Modifiers.DEFAULT_PLAYER.duplicate()
	
	# Reset Stats
	SaveData.current_game = SaveData.GameStats.new()

func _process(delta: float) -> void:
	$FPS.text = str(Engine.get_frames_per_second())
	
	SaveData.current_game.time += delta

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("left_click"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_FOCUS_IN:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

# DEFAULT_PLAYER
#	"max_stamina": 75
#	"max_health": 100
#	"dagger_damage_multiplier": 1
#	"bullet_damage_multiplier": 1
func add_positive_modifier():
	$Info.text = "[color=green]"
	
	match randi() % 4:
		0:
			Modifiers.player.max_stamina += 25
			$Info.text += "You can run for longer"
		1:
			Modifiers.player.max_health += 15
			$Player.get_node("Bars/Health").value += 25
			$Info.text += "You can hold more health"
		2:
			Modifiers.player.dagger_damage_multiplier += 0.4
			$Info.text += "Your Dagger does more damage"
		3:
			Modifiers.player.bullet_damage_multiplier += 0.2
			$Info.text += "Your Water Gun does more damage"

# DEFAULT_AARON
#	"health": 75
#	"speed_multiplier": 1
#	"damage_multiplier": 1
#	"ammo_drop_chance": 0.4
func add_negative_modifier():
	$Info.text = "[color=red]"
	
	match randi() % 5:
		0:
			Modifiers.aaron.health += 30
			$Info.text += "Aarons have more health"
		1:
			Modifiers.aaron.speed_multiplier += 0.15
			$Info.text += "Aarons run faster now"
		2:
			Modifiers.aaron.damage_multiplier += 0.25
			$Info.text += "Aarons do more damage"
		3:
			if Modifiers.aaron.ammo_drop_chance <= 0.1:
				add_negative_modifier()
				return
				
			Modifiers.aaron.ammo_drop_chance -= 0.05
			$Info.text += "Aarons drop less ammo"
		4:
			$SpawnTimer.wait_time -= 0.5
			$Info.text += "Aarons spawn more often"
	

func _on_spawn_timer_timeout() -> void:
	var point = get_tree().get_nodes_in_group("spawn_point").pick_random()
	
	if not point: return
	
	var aaron = aaron_scene.instantiate()
	aaron.position = point.global_position
	
	$Enemy.add_child(aaron)

func _on_add_modifier_timeout() -> void:
	$AnimationPlayer.play("show_text")
	
	var is_positive = bool(randi() % 2)
	
	if is_positive:
		$AudioPlayer.stream = preload("res://assets/sounds/positive.ogg")
		add_positive_modifier()
	else:
		$AudioPlayer.stream = preload("res://assets/sounds/negative.ogg")
		add_negative_modifier()
	
	$AudioPlayer.play()
