import game.{type Game}
import deck.{type Card}
import gleam/dict
import gleam/set
import util/validate as v

const target_in_attack = "That card is not present in the attack"

const defender_has_card = "The defender does not have that card"

const defence_beats_attack = "The defence does not beat the attack"

const attacker_has_card = "The attacker does not have that card"

pub fn can_first_attack(game: Game, with: Card) {
  v.check(attacker_has_card, set.contains(game.attacker, with))
}

pub fn can_defend(game: Game, against: Card, with: Card) {
  v.check(target_in_attack, dict.has_key(game.attack, against))
  |> v.and(defender_has_card, fn() { set.contains(game.defender, with) })
  |> v.and(defence_beats_attack, fn() { deck.beats(with, against, game.trump) })
}
