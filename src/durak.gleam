import gleam/io
import gleam/list.{drop, flat_map, last, map, shuffle, take}

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
    player1: List(Card),
    player2: List(Card),
    // Talon is another word for deck / library
    talon: List(Card),
    // We keep track of the trump suit even after the turnup has been found
    trump: Suit,
  )
}

pub fn new_game() {
  let deck = new_deck()
  let assert Ok(last_card) = last(deck)

  TwoPlayerGame(
    player1: deck
    |> take(6),
    player2: deck
    |> drop(6)
    |> take(6),
    talon: deck
    |> drop(12),
    trump: last_card.suit,
  )
}

pub fn main() {
  io.debug(new_game())
}
