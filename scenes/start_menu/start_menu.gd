extends Node3D

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept"):
		get_tree().change_scene_to_file("res://scenes/world/world.tscn")

func _on_slider_drag_ended(value_changed: bool) -> void:
	if value_changed:
		SaveData.settings.sensitivity = $Sensitivity/Slider.value
