import gleeunit
import gleeunit/should
import deck.{
  Ace, Card, Clubs, Diamonds, Eight, Hearts, Jack, King, Nine, Queen, Seven, Six,
  Spades, Ten,
}
import game.{TwoPlayerGame}
import durak.{Defend, attack, defend, new_game, subsiquent_attack}
import gleam/result.{then}
import gleam/set
import gleam/dict
import gleam/option.{None, Some}

pub fn main() {
  gleeunit.main()
}

pub fn example_game_test() {
  deck.new_deck()
  |> new_game()
  |> attack(Card(deck.Ten, deck.Spades))
  |> then(fn(game) {
    defend(game, Card(deck.Ten, deck.Spades), Card(deck.Ace, deck.Clubs))
  })
  |> then(fn(game) { subsiquent_attack(game, Card(deck.Ace, deck.Spades)) })
  |> should.equal(Ok(Defend(TwoPlayerGame(
    [
      Card(Jack, Clubs),
      Card(Ten, Clubs),
      Card(Nine, Clubs),
      Card(Eight, Clubs),
      Card(Seven, Clubs),
      Card(Six, Clubs),
      Card(Ace, Hearts),
      Card(King, Hearts),
      Card(Queen, Hearts),
      Card(Jack, Hearts),
      Card(Ten, Hearts),
      Card(Nine, Hearts),
      Card(Eight, Hearts),
      Card(Seven, Hearts),
      Card(Six, Hearts),
      Card(Ace, Diamonds),
      Card(King, Diamonds),
      Card(Queen, Diamonds),
      Card(Jack, Diamonds),
      Card(Ten, Diamonds),
      Card(Nine, Diamonds),
      Card(Eight, Diamonds),
      Card(Seven, Diamonds),
      Card(Six, Diamonds),
    ],
    Diamonds,
    set.from_list([
      Card(Jack, Spades),
      Card(King, Spades),
      Card(Nine, Spades),
      Card(Queen, Spades),
    ]),
    set.from_list([
      Card(Ace, Clubs),
      Card(Eight, Spades),
      Card(King, Clubs),
      Card(Queen, Clubs),
      Card(Seven, Spades),
      Card(Six, Spades),
    ]),
    dict.from_list([
      #(Card(Ace, Clubs), Some(Card(Ten, Spades))),
      #(Card(Ace, Spades), None),
      #(Card(Ten, Spades), None),
    ]),
  ))))
}
