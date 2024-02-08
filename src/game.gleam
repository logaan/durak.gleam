import deck.{type Card, type Deck, type Suit, Card}
import gleam/set
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

pub fn move_card_to_defend(game: Game, with: Card, against: Card) {
  TwoPlayerGame(
    ..game,
    defender: set.delete(game.defender, with),
    attack: dict.insert(game.attack, against, option.Some(with)),
  )
}

pub fn values_already_out(game: Game) {
  dict.fold(
    over: game.attack,
    from: set.new(),
    with: fn(already_out, key, value) {
      let already_out = set.insert(already_out, key.value)

      case value {
        None -> already_out
        Some(card) -> set.insert(already_out, card.value)
      }
    },
  )
}
