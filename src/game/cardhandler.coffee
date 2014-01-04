CardCache = require '../../lib/models/cardcache'

class CardHandler
  @playCard: (card, cardClass) ->
    # If the card doesn't have rush, then it is sleeping on first play
    if 'rush' not in cardClass.traits
      card.status.push 'sleeping'
    # Taunt cards have the taunt trait
    if 'taunt' in cardClass.traits
      card.status.push 'taunt'

  @updateFieldCardsOnTurn: (fieldCards) ->
    # On the next turn, remove the sleeping trait
    for card in fieldCards
      card.status = card.status.filter (t) -> t isnt 'sleeping'

module.exports = CardHandler
