import gleam/io
import gleam/list.{flat_map, map, shuffle}

pub type Suit {
  Spade
  Club
  Heart
  Diamond
}

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

pub type Card {
  Card(Suit, Value)
}

const suits = [Spade, Club, Heart, Diamond]

const values = [Ace, King, Queen, Jack, Ten, Nine, Eight, Seven, Six]

pub fn new_deck() {
  suits
  |> flat_map(fn(suit) { map(values, fn(value) { Card(suit, value) }) })
  |> shuffle()
}

pub fn main() {
  io.println("Hello from durak!")
}
