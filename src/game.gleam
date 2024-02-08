import deck.{type Card, type Deck, type Suit, Card}
import gleam/set
import gleam/option.{type Option}
import gleam/dict

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
