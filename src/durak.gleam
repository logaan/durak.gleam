import gleam/io
import gleam/list.{drop, flat_map, last, map, shuffle, split, take}

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

const suits = [Spades, Clubs, Hearts, Diamonds]

const values = [Ace, King, Queen, Jack, Ten, Nine, Eight, Seven, Six]

pub fn new_deck() {
  suits
  |> flat_map(fn(suit) { map(values, fn(value) { Card(value, suit) }) })
  |> shuffle()
}

pub type Game {
  TwoPlayerGame(
    players: List(List(Card)),
    // Talon is another word for deck / library
    talon: List(Card),
    // We keep track of the trump suit even after the turnup has been found
    trump: Suit,
    attacker: Int,
  )
}

pub fn new_game() {
  let deck = new_deck()

  let #(first_hand, deck) = split(deck, 6)
  let #(second_hand, deck) = split(deck, 6)

  let assert Ok(last_card) = last(deck)

  TwoPlayerGame(
    players: [first_hand, second_hand],
    talon: deck,
    trump: last_card.suit,
    attacker: 0,
  )
}

pub fn main() {
  io.debug(new_game())
}
