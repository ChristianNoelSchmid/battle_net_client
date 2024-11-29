extends Node 

var _player_sprites = [
	"Chris",
	"Alyssa Q",
	"Andrea",
	"Zach",
	"Alyssa C",
	"Kunane",
	"Brian",
	"Miranda",
	"Maria",
	"MJ",
	"Kim",
	"Paisley",
	"Cora",
]

var _enemy_sprites = [
	"Possessed Nutcraker",
	"Wildred the Esteemed Wizard",
]

func get_player_sprite(id):
	print("User ID: %d" % id)
	return load("res://assets/players/%s.png" % _player_sprites[id - 1])

func get_enemy_sprite(idx):
	return load("res://assets/battle/enemy_sprites/%s.png" % _enemy_sprites[idx])