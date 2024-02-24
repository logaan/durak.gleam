import deck.{type Card, type Deck, Card}
import game.{type Game} as g
import util/validate as v
import rules

pub type AttackerMustChooseAttack {
  AttackerMustChooseAttack(Game)
}

pub type DefenderMayDefendOrPass {
  DefenderMayDefendOrPass(Game)
}

pub type AttackerMayAttackOrPass {
  AttackerMayAttackOrPass(Game)
}

pub fn start_game(deck: Deck) {
  AttackerMustChooseAttack(g.new_game(deck))
}

pub fn start_attack(game_state: AttackerMustChooseAttack, card: Card) {
  let AttackerMustChooseAttack(game) = game_state

  rules.can_start_attack(game, card)
  |> v.then(fn() { DefenderMayDefendOrPass(g.move_card_to_attack(game, card)) })
}

pub fn join_attack(game_state: AttackerMayAttackOrPass, card: Card) {
  let AttackerMayAttackOrPass(game) = game_state

  rules.can_join_attack(game, card)
  |> v.then(fn() { DefenderMayDefendOrPass(g.move_card_to_attack(game, card)) })
}

pub fn defend(
  in game_state: DefenderMayDefendOrPass,
  against attacking: Card,
  with defending: Card,
) {
  let DefenderMayDefendOrPass(game) = game_state

  rules.can_defend(game, against: attacking, with: defending)
  |> v.then(fn() {
    AttackerMayAttackOrPass(g.move_card_to_defend(
      game,
      against: attacking,
      with: defending,
    ))
  })
}

pub fn pass_defence(in game_state: DefenderMayDefendOrPass) {
  let DefenderMayDefendOrPass(game) = game_state
  AttackerMayAttackOrPass(game)
}

pub fn pass_attack(in game_state: AttackerMayAttackOrPass) {
  let AttackerMayAttackOrPass(game) = game_state
  AttackerMustChooseAttack(g.end_round(game))
}
