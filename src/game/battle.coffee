Errors = require './errors'
CardCache = require '../../lib/models/cardcache'

class Battle
  constructor: (@model) ->
    @players = {}
    @sockets = {}
    @field = {}
    for player in @model.players
      cardsById = {}
      for card in player.deck.cards
        cardsById[card._id] = card
      player.cards = cardsById
      @players[player.userId] = player

  ###
  # EVENTS
  ###

  # Called when a user connects to this battle
  onConnect: (user, socket) ->
    @sockets[user._id] = socket
    @hookEvents user._id.toString(), socket

  # Called when the player is ready to start the battle
  onReady: (userId) ->
    (cb) =>
      if @model.state.phase == 'initial' and userId not in @model.state.playersReady
        @model.state.playersReady.push userId
        cb null
        if @model.state.playersReady.length is @model.players.length
          oldPhase = @model.state.phase
          @model.state.phase = 'game'
          @emitAll 'phase', oldPhase, @model.state.phase
          # Pick a random player to start and inform players' about their turn
          @assignNextActivePlayer()
          @emitAllButActive 'opponent-turn', @model.state.activePlayer
          @emitActive 'your-turn', @drawCard(@model.state.activePlayer)

      else
        cb Errors.INVALID_ACTION

  hookEvents: (userId, socket) ->
    socket.on 'ready', @onReady(userId)

  emitActive: (action, data...) ->
    @emit @model.state.activePlayer, action, data...

  emit: (userId, action, data...) ->
    @sockets[userId].emit action, data...

  emitAllButActive: (action, data...) ->
    @emitAllBut @model.state.activePlayer, action, data...

  emitAllBut: (ignore, action, data...) ->
    for userId, socket of @sockets
      if ignore isnt userId
        socket.emit action, data...

  emitAll: (action, data...) ->
    for userId, socket of @sockets
      socket.emit action, data...

  assignNextActivePlayer: ->
    if @model.state.activePlayer?
      @model.state.activePlayer = @getNextPlayer(@model.state.activePlayer).userId
    else
      @model.state.activePlayer = @getRandomPlayer().userId

  drawCard: (userId) ->
    deck = @getDeckCards(@players[userId])
    if deck.length is 0
      return null
    else
      drawnCard = deck[Math.floor(Math.random() * deck.length)]
      drawnCard.position = 'hand'
      return drawnCard

  getNextPlayer: (userId)->
    idx = @model.players.indexOf(userId)
    if idx is @model.players.length - 1
      idx = 0
    else
      idx++
    return @players[@model.players[idx]]

  getRandomPlayer: ->
    return @model.players[Math.floor(Math.random() * @model.players.length)]

  getFieldCards: (player) ->
    return player.deck.cards.filter (c) -> c.position is 'field'

  getHandCards: (player) ->
    return player.deck.cards.filter (c) -> c.position is 'hand'

  getDeckCards: (player) ->
    return player.deck.cards.filter (c) -> c.position is 'deck'

  sanitizeOpponentData: (player) ->
    out =
      hero: player.deck.hero #TODO: Make sure that all hero data is fine for the player to see (secrets and such should be stripped)
      field: @getFieldCards(player)
      handSize: @getHandCards(player).length # Player does not get to see opponent's cards
      deckSize: @getDeckCards(player).length

  getOpponentsData: (user) ->
    others = @model.players.filter (p) -> p.userId isnt user._id
    return others.map((o) => @sanitizeOpponentData(o))

  getData: (user) ->
    player = @players[user._id]
    out =
      you:
        hero: player.deck.hero
        field: @getFieldCards(player)
        hand: @getHandCards(player)
        deckSize: @getDeckCards(player).length # Player doesn't get to know what card is in deck
      opponents: @getOpponentsData(user)

module.exports = Battle
