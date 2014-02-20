class CardStats
  @stats: null

  @generate: (cards) ->
    if @stats?
      return @stats
    damagePerEnergy = {}
    healthPerEnergy = {}
    spells = {}
    minions = {}
    cardsById = {}

    for card in cards
      cardsById[card._id] = card
      if card.isSpellCard()
        spells[card._id] = card
      else
        minions[card._id] = card
        card.damagePerEnergy = card.damage / card.energy
        card.healthPerEnergy = card.health / card.energy

    @stats =
      cards:cardsById
      spells:spells
      minions:minions
    return @stats

module.exports = CardStats
