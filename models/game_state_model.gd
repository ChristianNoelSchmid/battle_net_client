extends Object
class_name GameStateModel

var user_id: int
var murdered_user_id: int
var user_stats: StatsModel
var user_cards: Array
var target_cards: Array
var winner_idxs: Array
var pl_exhausted: bool
var pl_completed_daily_riddle: bool
var pl_completed_all_riddles: bool
var pl_guessed_today: bool
var first_login: bool

func parse_variant(variant):
	user_id = variant.user_id
	murdered_user_id = variant.murdered_user_id
	user_stats = load("res://models/stats_model.gd").new()
	user_stats.parse_variant(variant.user_stats)

	user_cards = []
	for user_card in variant.user_cards:
		var card = load("res://models/user_card_model.gd").new()
		card.parse_variant(user_card)
		user_cards.push_back(card)   
	if variant.target_cards:
		target_cards = variant.target_cards
	if variant.winner_idxs:
		winner_idxs =  variant.winner_idxs

	pl_exhausted = variant.pl_exhausted
	pl_completed_daily_riddle = variant.pl_completed_daily_riddle
	pl_completed_all_riddles = variant.pl_completed_all_riddles
	pl_guessed_today = variant.pl_guessed_today
	first_login = variant.first_login

func player_won():
	return len(target_cards) > 0
