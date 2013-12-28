class User
  constructor: (@model) ->
    @id = @model._id

  hasDeck: (deckId) ->
    return @getDeck(deckId)?

  getDeck: (deckId) ->
    for deck in @model.decks
      if deck._id == deckId
        return deck
    return null

module.exports = User
