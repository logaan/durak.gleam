import deck.{type Card, type Deck, Card}
import game.{type Game} as g
import util/validate as v
import rules

pub type AttackersFirstTurn {
  AttackersFirstTurn(Game)
}

pub type AttackersTurn {
  AttackersTurn(Game)
}

pub type EndAttack {
  YieldToDefender(Game)
  DefenderLoses(Game)
}

pub type DefendersTurn {
  DefendersTurn(Game)
}

pub type EndDefence {
  YieldToAttacker(Game)
  AttackerLoses(Game)
}

pub fn start_game(deck: Deck) {
  AttackersFirstTurn(g.new_game(deck))
}

fn perform_attack(game: Game, card: Card) {
  let game = g.move_card_to_attack(game, card)

  case g.out_of_cards(game.attacker) {
    True -> DefenderLoses(game)
    False -> YieldToDefender(game)
  }
}

pub fn start_attack(game_state: AttackersFirstTurn, card: Card) {
  let AttackersFirstTurn(game) = game_state

  rules.can_start_attack(game, card)
  |> v.then(fn() { perform_attack(game, card) })
}

pub fn join_attack(game_state: AttackersTurn, card: Card) {
  let AttackersTurn(game) = game_state

  rules.can_join_attack(game, card)
  |> v.then(fn() { perform_attack(game, card) })
}

pub fn defend(
  in game_state: DefendersTurn,
  against attacking: Card,
  with defending: Card,
) {
  let DefendersTurn(game) = game_state

  rules.can_defend(game, against: attacking, with: defending)
  |> v.then(fn() {
    let game = g.move_card_to_defend(game, against: attacking, with: defending)

    case g.out_of_cards(game.defender) {
      True -> AttackerLoses(game)
      False -> YieldToAttacker(game)
    }
  })
}

pub fn pass_defence(in game_state: DefendersTurn) {
  let DefendersTurn(game) = game_state
  AttackersTurn(game)
}

pub fn pass_attack(in game_state: AttackersTurn) {
  let AttackersTurn(game) = game_state
  AttackersFirstTurn(g.end_round(game))
}
