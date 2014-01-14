MockCard = require './mockcard'
MockPlayer = require './mockplayer'

class MockBattle
  constructor: ->
    @cardHandlers = {}
    @cards = {}
    @players = {}
    @playerId = 0
    @cardId = 0

  NewCard: (player, opts) ->
    card = new MockCard(@cardId++, opts)
    player.deck.cards.push card
    @cards[card._id] = card
    return card

  NewPlayer: (opts) ->
    player = new MockPlayer(@playerId++, opts)
    @players[player._id] = player
    return player

  getHero: (heroId) ->
    for playerId, player of @players
      if player.deck.hero._id = heroId
        return player.deck.hero
    return null

  getCardHandler:(cardId) ->
    if @cards[cardId]?
      return @cards[cardId].handler
    return null

module.exports = MockBattle
