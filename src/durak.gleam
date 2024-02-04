import gleam/io
import gleam/list
import gleam/set
import gleam/option
import gleam/dict
import deck.{type Card, type Deck, type Suit, Card}
import util/list as ulist

pub type Hand =
  set.Set(Card)

type Attack =
  dict.Dict(Card, option.Option(Card))

pub type Game {
  TwoPlayerGame(
    talon: Deck,
    trump: Suit,
    attacker: Hand,
    defender: Hand,
    attack: Attack,
  )
}

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
  let #(first_hand, deck) = list.split(deck, 6)
  let #(second_hand, deck) = list.split(deck, 6)

  let assert Ok(last_card) = list.last(deck)

  FirstAttack(TwoPlayerGame(
    talon: deck,
    trump: last_card.suit,
    attacker: set.from_list(first_hand),
    defender: set.from_list(second_hand),
    attack: dict.new(),
  ))
}

pub fn attack(game_state: FirstAttack, card: Card) {
  let FirstAttack(game) = game_state
  let attacker_has_card = set.contains(game.attacker, card)

  case attacker_has_card {
    False -> Error("The attacker does not have that card")
    True ->
      Ok(Defend(
        TwoPlayerGame(
          ..game,
          attacker: set.delete(game.attacker, card),
          attack: dict.insert(game.attack, card, option.None),
        ),
      ))
  }
}

fn values_already_out(game: Game) {
  dict.fold(
    over: game.attack,
    from: set.new(),
    with: fn(already_out, key, value) {
      let already_out = set.insert(already_out, key.value)

      case value {
        option.None -> already_out
        option.Some(card) -> set.insert(already_out, card.value)
      }
    },
  )
}

pub fn subsiquent_attack(game_state: SubsiquentAttack, card: Card) {
  let SubsiquentAttack(game) = game_state
  let attacker_has_card = set.contains(game.attacker, card)
  let card_is_already_out = set.contains(values_already_out(game), card.value)

  case attacker_has_card, card_is_already_out {
    False, _ -> Error("The attacker does not have that card")
    _, False ->
      Error(
        "The attacking card has not previously been used to attack or defend",
      )
    True, True ->
      Ok(Defend(
        TwoPlayerGame(
          ..game,
          attacker: set.delete(game.attacker, card),
          attack: dict.insert(game.attack, card, option.None),
        ),
      ))
  }
}

pub fn defend(game_state: Defend, against: Card, with: Card) {
  let Defend(game) = game_state
  let attack_has_card = dict.has_key(game.attack, against)
  let defender_has_card = set.contains(game.defender, with)
  let defence_beats_attack = deck.beats(with, against, game.trump)

  case attack_has_card, defender_has_card, defence_beats_attack {
    False, _, _ -> Error("That card is not present in the attack")
    _, False, _ -> Error("The defender does not have that card")
    _, _, False -> Error("The defence does not beat the attack")
    True, True, True ->
      Ok(SubsiquentAttack(
        TwoPlayerGame(
          ..game,
          defender: set.delete(game.defender, with),
          attack: dict.insert(game.attack, against, option.Some(with)),
        ),
      ))
  }
}

pub fn main() {
  let deck = deck.new_deck()
  let game = new_game(deck)

  let assert Ok(game) = attack(game, Card(deck.Ten, deck.Spades))

  let assert Ok(game) =
    defend(game, Card(deck.Ten, deck.Spades), Card(deck.Ace, deck.Clubs))

  let assert Ok(_) = subsiquent_attack(game, Card(deck.Ace, deck.Spades))

  io.debug("Ok")

  let _ = ulist.test()
  let _ = deck.test()
}
