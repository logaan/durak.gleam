import game.{type Game, ranks_already_out}
import deck.{type Card}
import gleam/dict
import gleam/set
import util/validate as v

const target_in_attack = "That card is not present in the attack"

const defender_has_card = "The defender does not have that card"

const defence_beats_attack = "The defence does not beat the attack"

const attacker_has_card = "The attacker does not have that card"

const card_is_already_out = "The attacking card has not previously been used to attack or defend"

const too_many_attacks = "6 attacks have already been made"

pub fn can_start_attack(game: Game, with: Card) {
  v.check(attacker_has_card, set.contains(game.attacker, with))
}

pub fn can_join_attack(game: Game, with: Card) {
  v.check(attacker_has_card, set.contains(game.attacker, with))
  |> v.and(
    card_is_already_out,
    fn() { set.contains(ranks_already_out(game), with.rank) },
  )
  |> v.and(too_many_attacks, fn() { dict.size(game.attack) < 6 })
}

pub fn can_defend(in game: Game, against attacking: Card, with defending: Card) {
  v.check(target_in_attack, dict.has_key(game.attack, attacking))
  |> v.and(defender_has_card, fn() { set.contains(game.defender, defending) })
  |> v.and(
    defence_beats_attack,
    fn() { deck.beats(defending, attacking, game.trump) },
  )
}
