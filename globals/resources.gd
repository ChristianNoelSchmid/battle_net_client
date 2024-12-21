extends Node 

var _cards = [

	[[0, 0], "alyssa c"],
	[[0, 1], "alyssa q"],
	[[0, 2], "andrea"],
	[[0, 3], "brian"],
	[[0, 4], "chris"],
	[[0, 5], "coraline"],
	[[0, 6], "kim"],
	[[0, 7], "kunane"],
	[[0, 8], "maria"],
	[[0, 9], "miranda"],
	[[0, 10], "mj"],
	[[0, 11], "paisley"],
	[[0, 12], "zach"],
	[[1, 0], "nutcracker"],
	[[1, 1], "fruitcake"],
	[[1, 2], "uglysweater"],
	[[1, 3], "ornamentbarrage"],
	[[1, 4], "candycaneshank"],
	[[2, 0], "elf"],
	[[2, 1], "thepolarexpress"],
	[[2, 2], "thegrinch"],
	[[2, 3], "amuppetxmascarroll"],
	[[2, 4], "itsawonderfullife"],
]

var _player_sprites = [
	"Alyssa C",
	"Alyssa Q",
	"Andrea",
 	"Brian",
	"Chris",
	"Coraline",
	"Kim",
	"Kunane",
	"Maria",
	"Miranda",
	"MJ",
	"Paisley",
	"Zach",
]

var _enemy_sprites = [
	"Wilfred the Esteemed Wizard",
	"Possessed Nutcracker",
	"Evil Chris",
]

func get_player_sprite(id):
	print("User ID: %d" % id)
	return load("res://assets/players/%s.png" % _player_sprites[id - 1])

func get_enemy_sprite(idx):
	print("Monster idx: %d" % idx)
	return load("res://assets/enemies/%s.png" % _enemy_sprites[idx])

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
