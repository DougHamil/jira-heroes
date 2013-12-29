async = require 'async'
Cards = require '../../lib/models/card'

###
# Simple cache for cards
###
class CardCache
  @cards: {}
  @loadCard: (cardId, cb) ->
    if @cards[cardId]?
      cb null, @cards[cardId]
    else
      Cards.get cardId, (err, card) =>
        if err?
          cb err
        else
          @cards[card._id] = card
          cb null, card

  @load: (cardIds, cb) ->
    async.map cardIds, CardCache.loadCard, cb

module.exports = CardCache
