clone = require 'clone'
Errors = require './errors'

PHASE =
  INITIAL: 'INITIAL'

class Battle
  constructor: (@model, @players) ->
    @sockets = {}
    if not @model._id?
      # TODO: Initial battle configuration
      @initialize()
    else
      # Restore from persisted model

  initialize: ->
    @model.players = {}
    @model.phase = PHASE.INITIAL

  onPlayerJoined: (user, hero, cards) ->
    player =
      user:user._id
      hero:hero
      deck:cards
      hand: []
    @model.players[player.user] = player

  onPlayerConnected: (user, socket) ->
    @sockets[user._id] = socket

module.exports = Battle
