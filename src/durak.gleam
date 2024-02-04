import gleam/io
import gleam/list
import gleam/set
import gleam/option
import gleam/dict
import deck.{type Card, type Deck, type Suit, Card}
import util/list as ulist

pub type Hand =
  set.Set(Card)

type Attack =
  dict.Dict(Card, option.Option(Card))

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

pub fn attack(game: Game, card: Card) {
  case set.contains(game.attacker, card) {
    True ->
      Ok(
        TwoPlayerGame(
          ..game,
          attacker: set.delete(game.attacker, card),
          attack: dict.insert(game.attack, card, option.None),
        ),
      )
    False -> Error("The attacker does not have that card")
  }
}

pub fn defend(game: Game, against: Card, with: Card) {
  let attack_has_card = dict.has_key(game.attack, against)
  let defender_has_card = set.contains(game.defender, with)
  let defence_beats_attack = deck.beats(with, against, game.trump)

  case attack_has_card, defender_has_card, defence_beats_attack {
    False, _, _ -> Error("That card is not present in the attack")
    _, False, _ -> Error("The defender does not have that card")
    _, _, False -> Error("The defence does not beat the attack")
    True, True, True ->
      Ok(
        TwoPlayerGame(
          ..game,
          defender: set.delete(game.defender, with),
          attack: dict.insert(game.attack, against, option.Some(with)),
        ),
      )
  }
}

pub fn main() {
  let deck = deck.new_deck()
  let game = new_game(deck)

  let assert Ok(game) = attack(game, Card(deck.Ace, deck.Spades))

  let assert Ok(_) =
    defend(game, Card(deck.Ace, deck.Spades), Card(deck.Eight, deck.Spades))

  io.debug("Ok")

  let _ = ulist.test()
  let _ = deck.test()
}
