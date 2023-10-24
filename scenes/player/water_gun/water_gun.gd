extends Node3D
class_name WaterGun

var disabled := false

var bullet_scene: PackedScene = preload("bullet/bullet.tscn")

var mag_size := 20
var current_ammo := 20

var ammo_owner: Player

func _ready() -> void:
	ammo_owner = get_tree().get_first_node_in_group("player")
	
	if not ammo_owner:
		var fake_player = Player.new()
		fake_player.ammo = 999
		ammo_owner = fake_player
	
	update_ammo_label()

func _process(_delta: float) -> void:
	if $AnimationPlayer.is_playing() or disabled:
		return
	
	if Input.is_action_pressed("left_click"):
		if not current_ammo:
			$AnimationPlayer.play("reload")
			return
		
		$AnimationPlayer.play("shoot")
		$ShootSound.play()
		
		var bullet := bullet_scene.instantiate()
		bullet.position = $BulletSpawn.position
		add_child(bullet)
		
		current_ammo -= 1
		update_ammo_label()
		
	elif Input.is_action_pressed("reload") and current_ammo != mag_size:
		$AnimationPlayer.play("reload")

func update_ammo_label():
	$Panel/AmmoLabel.text = "%d/%d" % [current_ammo, ammo_owner.ammo]

func reload():
	var ammo_to_fill = mag_size - current_ammo
	
	if ammo_to_fill > ammo_owner.ammo:
		ammo_to_fill = ammo_owner.ammo
		ammo_owner.ammo = 0
	else:
		ammo_owner.ammo -= ammo_to_fill
	
	current_ammo += ammo_to_fill
	update_ammo_label()
