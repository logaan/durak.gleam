import gleam/list
import gleam/order
import gleam/int
import util/list.{index} as _

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

const suits = [Spades, Clubs, Hearts, Diamonds]

const values = [Ace, King, Queen, Jack, Ten, Nine, Eight, Seven, Six]

pub fn new_deck() {
  list.flat_map(
    suits,
    fn(suit) { list.map(values, fn(value) { Card(value, suit) }) },
  )
}

pub fn beats(left: Card, right: Card, trump: Suit) {
  case compare(left, right, trump) {
    order.Gt -> True
    _ -> False
  }
}

pub fn compare(left: Card, right: Card, trump: Suit) {
  case left, right, trump {
    // Left trump wins
    Card(_, ls), Card(_, rs), t if ls == t && rs != t -> order.Gt
    // Right trump wins
    Card(_, ls), Card(_, rs), t if ls != t && rs == t -> order.Lt
    // Same value (but neither is a trump) is equal
    // This case might actually be covered by the one below
    Card(lv, _), Card(rv, _), _ if lv == rv -> order.Eq
    // Otherwise compare the values
    Card(lv, _), Card(rv, _), _ -> {
      let assert Ok(lindex) = index(of: lv, in: values)
      let assert Ok(rindex) = index(of: rv, in: values)
      order.negate(int.compare(lindex, rindex))
    }
  }
}
