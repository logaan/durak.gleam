import gleeunit/should
import deck.{
  Ace, Card, Clubs, Diamonds, Eight, Hearts, Jack, King, Nine, Queen, Seven, Six,
  Spades, Ten,
}
import game.{TwoPlayerGame}
import game_states.{
  defend, join_attack, pass_attack, pass_defence, start_attack, start_game,
} as gs
import gleam/result.{then}
import gleam/set
import gleam/dict
import gleam/option

fn yield_to_defender(state: gs.EndAttack) {
  case state {
    gs.YieldToDefender(game) -> Ok(gs.DefendersTurn(game))
    gs.DefenderLoses(_) -> panic as "The tests know we can't get here"
  }
}

fn yield_to_attacker(state: gs.EndDefence) {
  case state {
    gs.YieldToAttacker(game) -> Ok(gs.AttackersTurn(game))
    gs.AttackerLoses(_) -> panic as "The tests know we can't get here"
  }
}

pub fn first_round_test() {
  let deck = deck.new_deck()

  start_game(deck)
  |> start_attack(Card(deck.Ten, deck.Spades))
  |> then(fn(state) { yield_to_defender(state) })
  |> then(fn(game) {
    defend(
      in: game,
      against: Card(deck.Ten, deck.Spades),
      with: Card(deck.Ace, deck.Clubs),
    )
  })
  |> then(fn(state) { yield_to_attacker(state) })
  |> then(fn(game) { join_attack(game, Card(deck.Ace, deck.Spades)) })
  |> then(fn(state) { yield_to_defender(state) })
  |> then(fn(game) { Ok(pass_defence(game)) })
  |> then(fn(game) { Ok(pass_attack(game)) })
  |> should.equal(Ok(gs.AttackersFirstTurn(TwoPlayerGame(
    talon: [
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
    trump: Diamonds,
    attacker: set.from_list([
      Card(Jack, Spades),
      Card(King, Spades),
      Card(Nine, Spades),
      Card(Queen, Spades),
      Card(Jack, Clubs),
      Card(Ten, Clubs),
    ]),
    defender: set.from_list([
      Card(Eight, Spades),
      Card(King, Clubs),
      Card(Queen, Clubs),
      Card(Seven, Spades),
      Card(Six, Spades),
      Card(Ace, Spades),
      Card(Ten, Spades),
      Card(Ace, Clubs),
    ]),
    attack: dict.from_list([]),
  ))))
}

pub fn defence_lose_test() {
  let starting_game =
    game.TwoPlayerGame(
      talon: [],
      trump: Hearts,
      attacker: set.from_list([Card(Ace, Hearts)]),
      defender: set.from_list([Card(Ace, Clubs)]),
      attack: dict.new(),
    )

  let joining_game =
    game.TwoPlayerGame(
      ..starting_game,
      attack: dict.from_list([
        #(Card(Ten, Spades), option.Some(Card(Ace, Spades))),
      ]),
    )

  let defence_lose_from_first =
    start_attack(gs.AttackersFirstTurn(starting_game), Card(Ace, Hearts))
  let defence_lose_from_joined =
    join_attack(gs.AttackersTurn(joining_game), Card(Ace, Hearts))

  should.equal(
    defence_lose_from_first,
    Ok(gs.DefenderLoses(
      game.TwoPlayerGame(
        ..starting_game,
        attacker: set.new(),
        attack: dict.from_list([#(Card(Ace, Hearts), option.None)]),
      ),
    )),
  )

  should.equal(
    defence_lose_from_joined,
    Ok(gs.DefenderLoses(
      game.TwoPlayerGame(
        ..joining_game,
        attacker: set.new(),
        attack: dict.from_list([
          #(Card(Ten, Spades), option.Some(Card(Ace, Spades))),
          #(Card(Ace, Hearts), option.None),
        ]),
      ),
    )),
  )
}
