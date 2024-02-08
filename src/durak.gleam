// TODO: Rename to game_states
import deck.{type Card, type Deck, Card}
import game.{type Game}
import util/validate as v
import rules

pub type FirstAttack {
  FirstAttack(Game)
}

pub type Defend {
  Defend(Game)
}

pub type SubsiquentAttack {
  SubsiquentAttack(Game)
}

pub fn new_game(deck: Deck) {
  FirstAttack(game.new_game(deck))
}

// TODO: Rename to start attack
pub fn attack(game_state: FirstAttack, card: Card) {
  let FirstAttack(game) = game_state

  rules.can_first_attack(game, card)
  |> v.then(fn() { Defend(game.move_card_to_attack(game, card)) })
}

// TODO: Rename to join attack
pub fn subsiquent_attack(game_state: SubsiquentAttack, card: Card) {
  let SubsiquentAttack(game) = game_state

  rules.can_join_attack(game, card)
  |> v.then(fn() { Defend(game.move_card_to_attack(game, card)) })
}

pub fn defend(game_state: Defend, against: Card, with: Card) {
  let Defend(game) = game_state

  rules.can_defend(game, against, with)
  |> v.then(fn() {
    SubsiquentAttack(game.move_card_to_defend(game, against, with))
  })
}
