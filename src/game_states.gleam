import deck.{type Card, type Deck, Card}
import game.{type Game} as g
import util/validate as v
import rules

pub type StartAttack {
  StartAttack(Game)
}

pub type Defend {
  Defend(Game)
}

pub type JoinAttack {
  JoinAttack(Game)
}

pub fn start_game(deck: Deck) {
  StartAttack(g.new_game(deck))
}

pub fn start_attack(game_state: StartAttack, card: Card) {
  let StartAttack(game) = game_state

  rules.can_start_attack(game, card)
  |> v.then(fn() { Defend(g.move_card_to_attack(game, card)) })
}

pub fn join_attack(game_state: JoinAttack, card: Card) {
  let JoinAttack(game) = game_state

  rules.can_join_attack(game, card)
  |> v.then(fn() { Defend(g.move_card_to_attack(game, card)) })
}

pub fn defend(
  in game_state: Defend,
  against attacking: Card,
  with defending: Card,
) {
  let Defend(game) = game_state

  rules.can_defend(game, against: attacking, with: defending)
  |> v.then(fn() {
    JoinAttack(g.move_card_to_defend(game, against: attacking, with: defending))
  })
}

pub fn pass_defence(in game_state: Defend) {
  let Defend(game) = game_state
  JoinAttack(game)
}

pub fn pass_attack(in game_state: JoinAttack) {
  let JoinAttack(game) = game_state
  StartAttack(g.end_turn(game))
}
