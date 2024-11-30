extends Node 

var _cards = [
	[[0, 0], "chris"],
	[[0, 1], "alyssa q"],
	[[0, 2], "andrea"],
	[[0, 3], "zach"],
	[[0, 4], "alyssa c"],
	[[0, 5], "kunane"],
	[[0, 6], "brian"],
	[[0, 7], "miranda"],
	[[0, 8], "maria"],
	[[0, 9], "mj"],
	[[0, 10], "kim"],
	[[1, 0], "nutcracker"],
	[[1, 1], "fruitcake"],
	[[1, 2], "uglysweater"],
	[[1, 3], "ornamentbarrage"],
	[[1, 4], "candycaneshank"],
	[[2, 0], "elf"],
	[[2, 1], "thepolarexpress"],
	[[2, 2], "thegrinch"],
]

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
	"Possessed Nutcracker",
	"Wilfred the Esteemed Wizard",
]

func get_player_sprite(id):
	print("User ID: %d" % id)
	return load("res://assets/players/%s.png" % _player_sprites[id - 1])

func get_enemy_sprite(idx):
	return load("res://assets/enemies/%s.png" % _enemy_sprites[idx - 1])

func get_card_sprite(cat_idx, card_idx) -> Texture:
	for i in len(_cards):
		if _cards[i][0][0] == cat_idx && _cards[i][0][1] == card_idx:
			return load("res://assets/cards/%s.png" % _cards[i][1])	
	return null
			
func get_cat_card_idxs() -> Array:
	var idxs = []
	for i in len(_cards):
		idxs.push_back(_cards[i][0])
	return idxs
