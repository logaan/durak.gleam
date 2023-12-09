import gleam/io
import gleam/list
import gleam/set
import gleam/option
import gleam/dict
import gleam/order

pub type Value {
  Ace
  King
  Queen
  Jack
  Ten
  Nine
  Eight
  Seven
  Six
}

pub type Suit {
  Spades
  Clubs
  Hearts
  Diamonds
}

pub type Card {
  Card(value: Value, suit: Suit)
}

pub type Deck =
  List(Card)

pub type Hand =
  set.Set(Card)

pub type Player =
  Hand

const suits = [Spades, Clubs, Hearts, Diamonds]

const values = [Ace, King, Queen, Jack, Ten, Nine, Eight, Seven, Six]

pub fn new_deck() {
  list.flat_map(
    suits,
    fn(suit) { list.map(values, fn(value) { Card(value, suit) }) },
  )
}

type Attack =
  dict.Dict(Card, option.Option(Card))

pub type Game {
  TwoPlayerGame(
    talon: Deck,
    trump: Suit,
    attacker: Player,
    defender: Player,
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

// At a high level this funtion should:
// 1. Check that `against` is present in the attack
// 2. Check that `with` is in the defender's hand
// 3. TODO Check that `with` beats `against`
// 4. Update the game
pub fn defend(game: Game, against: Card, with: Card) {
  let attack_has_card = dict.has_key(game.attack, against)
  let defender_has_card = set.contains(game.defender, with)

  case attack_has_card, defender_has_card {
    False, _ -> Error("That card is not present in the attack")
    _, False -> Error("The defender does not have that card")
    True, True ->
      Ok(
        TwoPlayerGame(
          ..game,
          defender: set.delete(game.defender, with),
          attack: dict.insert(game.attack, against, option.Some(with)),
        ),
      )
  }
}

fn count_index(of needle: a, in haystack: List(a), having seen: Int) {
  case haystack {
    [] -> Error("Needle was not found in haystack")
    [head, ..] if head == needle -> Ok(seen)
    [_, ..tail] -> count_index(of: needle, in: tail, having: seen + 1)
  }
}

fn index(of needle: a, in haystack: List(a)) {
  count_index(0, of: needle, in: haystack)
}

pub fn main() {
  let deck = new_deck()
  let game = new_game(deck)
  io.debug(game)

  io.debug("")

  let assert Ok(game) = attack(game, Card(Ace, Spades))
  io.debug(game)

  io.debug("")

  let assert Ok(game) = defend(game, Card(Ace, Spades), Card(Eight, Spades))
  io.debug(game)

  let assert Ok(0) = index(of: "a", in: ["a", "b", "c"])
  let assert Ok(1) = index(of: "b", in: ["a", "b", "c"])
  let assert Ok(2) = index(of: "c", in: ["a", "b", "c"])
  let assert Error(_) = index(of: "d", in: ["a", "b", "c"])
}
