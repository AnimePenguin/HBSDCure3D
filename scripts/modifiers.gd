extends Node

const DEFAULT_AARON := {
	"health": 75,
	"speed_multiplier": 1,
	"damage_multiplier": 1,
	"ammo_drop_chance": 0.4,
}

const DEFAULT_PLAYER := {
	"max_stamina": 75,
	"max_health": 100,
	"dagger_damage_multiplier": 1,
	"bullet_damage_multiplier": 1,
}

var aaron := DEFAULT_AARON.duplicate()
var player := DEFAULT_PLAYER.duplicate()
