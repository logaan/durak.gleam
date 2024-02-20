import gleeunit/should
import deck.{
  Ace, Card, Clubs, Diamonds, Eight, Hearts, Jack, King, Nine, Queen, Seven, Six,
  Spades, Ten,
}
import game.{TwoPlayerGame}
import game_states.{defend, join_attack, pass_defence, start_attack, start_game}
import gleam/result.{then}
import gleam/set
import gleam/dict
import gleam/option.{None, Some}

pub fn example_game_test() {
  let deck = deck.new_deck()

  start_game(deck)
  |> start_attack(Card(deck.Ten, deck.Spades))
  |> then(fn(game) {
    defend(
      in: game,
      against: Card(deck.Ten, deck.Spades),
      with: Card(deck.Ace, deck.Clubs),
    )
  })
  |> then(fn(game) { join_attack(game, Card(deck.Ace, deck.Spades)) })
  |> then(fn(game) { Ok(pass_defence(game)) })
  |> should.equal(Ok(game_states.JoinAttack(TwoPlayerGame(
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
      Card(Eight, Spades),
      Card(King, Clubs),
      Card(Queen, Clubs),
      Card(Seven, Spades),
      Card(Six, Spades),
    ]),
    dict.from_list([
      #(Card(Ace, Spades), None),
      #(Card(Ten, Spades), Some(Card(Ace, Clubs))),
    ]),
  ))))
}
