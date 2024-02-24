import deck.{type Card, type Deck, type Suit, Card}
import gleam/set.{type Set}
import gleam/option.{type Option, None, Some}
import gleam/dict
import gleam/list

pub type Hand =
  set.Set(Card)

type Attack =
  dict.Dict(Card, Option(Card))

pub type Game {
  TwoPlayerGame(
    talon: Deck,
    trump: Suit,
    attacker: Hand,
    defender: Hand,
    attack: Attack,
  )
}

pub fn new_game(deck: Deck) {
  let #(first_hand, deck) = list.split(deck, 6)
  let #(second_hand, deck) = list.split(deck, 6)

  let assert Ok(last_card) = list.last(deck)

  TwoPlayerGame(
    talon: deck,
    trump: last_card.suit,
    attacker: set.from_list(first_hand),
    defender: set.from_list(second_hand),
    attack: dict.new(),
  )
}

pub fn move_card_to_attack(game: Game, card: Card) {
  TwoPlayerGame(
    ..game,
    attacker: set.delete(game.attacker, card),
    attack: dict.insert(game.attack, card, option.None),
  )
}

pub fn move_card_to_defend(
  in game: Game,
  with defending: Card,
  against attacking: Card,
) {
  TwoPlayerGame(
    ..game,
    defender: set.delete(game.defender, defending),
    attack: dict.insert(game.attack, attacking, option.Some(defending)),
  )
}

pub fn ranks_already_out(game: Game) {
  dict.fold(
    over: game.attack,
    from: set.new(),
    with: fn(already_out, key, rank) {
      let already_out = set.insert(already_out, key.rank)

      case rank {
        None -> already_out
        Some(card) -> set.insert(already_out, card.rank)
      }
    },
  )
}

fn successful_defence(game: Game) -> Bool {
  game.attack
  |> dict.values()
  |> list.all(fn(v) { option.is_some(v) })
}

fn all_cards_in_attack(game: Game) -> Set(Card) {
  let attacks = dict.keys(game.attack)
  let defences =
    game.attack
    |> dict.values()
    |> list.filter_map(fn(o) { option.to_result(o, "Undefended") })

  set.from_list(list.append(attacks, defences))
}

fn defender_draws_unless_successful(game: Game, defender_won: Bool) -> Game {
  let new_defender_hand = case defender_won {
    True -> game.defender
    False -> set.union(game.defender, all_cards_in_attack(game))
  }

  TwoPlayerGame(..game, defender: new_defender_hand, attack: dict.new())
}

fn draw_to_hand(talon: Deck, cards_to_draw: Int, hand: Hand) {
  #(
    list.take(talon, cards_to_draw)
    |> set.from_list()
    |> set.union(hand),
    list.drop(talon, cards_to_draw),
  )
}

fn restock_hands(game: Game) -> Game {
  let attacker_cards_to_draw = 6 - set.size(game.attacker)
  let defender_cards_to_draw = 6 - set.size(game.defender)

  let #(new_attacker, new_talon) =
    draw_to_hand(game.talon, attacker_cards_to_draw, game.attacker)
  let #(new_defender, new_talon) =
    draw_to_hand(new_talon, defender_cards_to_draw, game.defender)

  TwoPlayerGame(
    ..game,
    talon: new_talon,
    attacker: new_attacker,
    defender: new_defender,
  )
}

fn switch_defender(game: Game, defender_won: Bool) -> Game {
  case defender_won {
    True ->
      TwoPlayerGame(..game, attacker: game.defender, defender: game.attacker)
    False -> game
  }
}

pub fn end_round(game: Game) {
  let defender_won = successful_defence(game)

  game
  |> defender_draws_unless_successful(defender_won)
  |> restock_hands()
  |> switch_defender(defender_won)
}

pub fn out_of_cards(hand: Hand) {
  set.size(hand) == 0
}
