import gleam/list
import gleam/order
import gleam/int
import util/list.{index} as _

pub type Rank {
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
  Card(rank: Rank, suit: Suit)
}

pub type Deck =
  List(Card)

const suits = [Spades, Clubs, Hearts, Diamonds]

const ranks = [Ace, King, Queen, Jack, Ten, Nine, Eight, Seven, Six]

pub fn new_deck() {
  list.flat_map(
    suits,
    fn(suit) { list.map(ranks, fn(rank) { Card(rank, suit) }) },
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
    // Same rank (but neither is a trump) is equal
    // This case might actually be covered by the one below
    Card(lv, _), Card(rv, _), _ if lv == rv -> order.Eq
    // Otherwise compare the ranks
    Card(lv, _), Card(rv, _), _ -> {
      let assert Ok(lindex) = index(of: lv, in: ranks)
      let assert Ok(rindex) = index(of: rv, in: ranks)
      order.negate(int.compare(lindex, rindex))
    }
  }
}
