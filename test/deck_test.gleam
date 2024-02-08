import deck.{compare} as d
import gleam/order
import gleeunit
import gleeunit/should

pub fn main() {
  gleeunit.main()
}

pub fn compare_test() {
  let cas = d.Card(d.Ace, d.Spades)
  let c6s = d.Card(d.Six, d.Spades)
  let cad = d.Card(d.Ace, d.Diamonds)
  let c6d = d.Card(d.Six, d.Diamonds)

  // Lower values trump higher ones
  compare(c6s, cad, d.Spades)
  |> should.equal(order.Gt)

  compare(cas, c6d, d.Diamonds)
  |> should.equal(order.Lt)

  // Non trump values order by value across suits
  compare(cas, cad, d.Clubs)
  |> should.equal(order.Eq)

  compare(cas, c6d, d.Clubs)
  |> should.equal(order.Gt)

  compare(c6s, cad, d.Clubs)
  |> should.equal(order.Lt)
}
