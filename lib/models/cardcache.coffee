async = require 'async'
Cards = require '../../lib/models/card'

###
# Simple cache for cards
###
class CardCache
  @cards: {}
  @getCard: (cardId, cb) ->
    if @cards[cardId]?
      cb null, @cards[cardId]
    else
      Cards.get cardId, (err, card) =>
        if err?
          cb err
        else
          @cards[card._id] = card
          cb null, card

  @get: (cardIds, cb) ->
    if typeof cardIds is 'string'
      @getCard cardIds, cb
    else
      async.map cardIds, CardCache.loadCard, cb

module.exports = CardCache
