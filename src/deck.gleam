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

pub fn test() {
  let cas = Card(Ace, Spades)
  let c6s = Card(Six, Spades)
  let cad = Card(Ace, Diamonds)
  let c6d = Card(Six, Diamonds)

  // Lower values trump higher ones
  let assert order.Gt = compare(c6s, cad, Spades)
  let assert order.Lt = compare(cas, c6d, Diamonds)

  // Non trump values order by value across suits
  let assert order.Eq = compare(cas, cad, Clubs)
  let assert order.Gt = compare(cas, c6d, Clubs)
  let assert order.Lt = compare(c6s, cad, Clubs)
}
