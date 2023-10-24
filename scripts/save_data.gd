extends Node

const SETTINGS_PATH = "user://settings.json"

class GameStats:
	var time: float = 0
	var aarons_killed: int = 0
	
	func get_as_list() -> Array:
		return [roundi(self.time), self.aarons_killed]

var current_game := GameStats.new()

var settings := {
	"sensitivity": 0.5
}
	
func _ready() -> void:
	if FileAccess.file_exists(SETTINGS_PATH):
		var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
		settings = JSON.parse_string(file.get_as_text())

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
		file.store_string(JSON.stringify(settings))
