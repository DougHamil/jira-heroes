Errors = require './errors'
CardCache = require '../../lib/models/cardcache'

class Battle
  constructor: (@model) ->
    @players = {}
    @sockets = {}
    for player in @model.players
      cardsById = {}
      for card in player.deck.cards
        cardsById[card._id] = card
      player.cards = cardsById
      @players[player.userId] = player

  onConnect: (user, socket) ->
    @sockets[user._id] = socket

  getData: (user) ->
    out =
      you: @players[user._id]

module.exports = Battle
