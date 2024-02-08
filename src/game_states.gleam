import deck.{type Card, type Deck, Card}
import game.{type Game}
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
  StartAttack(game.new_game(deck))
}

pub fn start_attack(game_state: StartAttack, card: Card) {
  let StartAttack(game) = game_state

  rules.can_start_attack(game, card)
  |> v.then(fn() { Defend(game.move_card_to_attack(game, card)) })
}

pub fn join_attack(game_state: JoinAttack, card: Card) {
  let JoinAttack(game) = game_state

  rules.can_join_attack(game, card)
  |> v.then(fn() { Defend(game.move_card_to_attack(game, card)) })
}

pub fn defend(
  in game_state: Defend,
  against attacking: Card,
  with defending: Card,
) {
  let Defend(game) = game_state

  rules.can_defend(game, against: attacking, with: defending)
  |> v.then(fn() {
    JoinAttack(game.move_card_to_defend(
      game,
      against: attacking,
      with: defending,
    ))
  })
}
