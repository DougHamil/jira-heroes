Errors = require './errors'
async = require 'async'
{EventEmitter} = require 'events'
Abilities = require './abilities'
BattleHelpers = require '../../lib/common/battlehelpers'
DrawCardAction = require './actions/drawcard'
StartTurnAction = require './actions/startturn'
ActionProcessor = require './actionprocessor'
CardCache = require '../../lib/models/cardcache'
PlayerHandler = require './playerhandler'
BotHandler = require './bothandler'
CardHandler = require './cardhandler'
Actions = require './actions'
Events = require './events'

CARDS_DRAWN_PER_TURN = 1 # Number of cards to draw each turn
INITIAL_CARD_COUNT = 3 # Second turn player gets 3 cards to start
ENERGY_INCREASE_PER_TURN = 1

class Battle extends EventEmitter
  constructor: (@model) ->
    super
    BattleHelpers.addMethodsToBattle(@model)
    @players = {}
    @sockets = {}
    @field = {}
    @cards = {}
    @abilities = []
    for player in @model.players
      if @model.isVirtual? or (player.isBot? and player.isBot)
        @players[player.userId] = new BotHandler(@, player)
      else
        @players[player.userId] = new PlayerHandler(@, player)
      cardsById = {}
      for card in player.deck.cards
        cardsById[card._id] = card
        @cards[card._id] = new CardHandler(@, @players[player.userId], card)
      player.cards = cardsById
      @registerPlayer(player.userId, @players[player.userId])

    # Restore passive abilities
    for abilityModel in @model.passiveAbilities
      source = @cards[abilityModel.sourceId]
      source = source.model if source?
      # Don't do the onregister callback again, because we're just restoring
      @registerPassiveAbility Abilities.RestoreFromModel(source, abilityModel), false

    # Start the battle if it's still in initial phase
    if @model.state.phase is 'initial'
      @startGame()

  clone: ->
    clonedModel = JSON.parse(JSON.stringify(@model))
    clonedModel.isVirtual = true
    return new Battle(clonedModel)

  registerPlayer: (userId, handler) ->
    handler.on Events.PLAY_CARD, @onPlayCard(userId)               # Deploy card from hand to field
    handler.on Events.END_TURN, @onEndTurn(userId)                 # Turn over
    handler.on Events.USE_CARD, @onUseCard(userId)                 # Player used a card, targeting something

  ###
  # EVENTS
  ###
  # Called when a user disconnects from this battle
  onDisconnect: (user) ->
    @players[user._id.toString()].disconnect()
    delete @sockets[user._id]
    @emitAll 'player-disconnected', user._id

  # Called when a user connects to this battle
  onConnect: (user, socket) ->
    @players[user._id.toString()].connect socket
    @sockets[user._id] = socket
    @emitAllBut user._id.toString(), 'player-connected', user._id

  # Called when a player used a card, targeting another card
  onUseCard: (userId) ->
    (actions) =>
      @emitAllButActive 'opponent-'+Events.USE_CARD, userId
      @emitActionsAll 'action', actions

  # Called when the player has played a card
  onPlayCard: (userId) ->
    (actions) =>
      @emitAllButActive 'opponent-'+Events.PLAY_CARD, userId
      @emitActionsAll 'action', actions

  # Called when the player has completed his turn
  onEndTurn: (userId) ->
    (actions) =>
      @emitAllButActive 'opponent-'+Events.END_TURN, userId
      @emitActionsAll 'action', actions
      @nextTurn()

  # Registers an ability as active and the ability will be passed all events
  registerPassiveAbility: (ability, doCallback) ->
    doCallback = true if not doCallback?
    @model.passiveAbilities.push ability.model
    @abilities.push ability
    if doCallback
      actions = []
      if ability.onRegistered?
        actions = ability.onRegistered(@)
      if not actions instanceof Array
        actions = []
      return actions

  # Removes an ability from registry, this de-activates the ability.
  unregisterPassiveAbility: (ability) ->
    @abilities.splice(@abilities.indexOf(ability), 1)
    @model.passiveAbilities.splice(@model.passiveAbilities.indexOf(ability.model), 1)
    actions = []
    if ability.onUnregistered?
      actions = ability.onUnregistered(@)
    if actions? and actions not instanceof Array
      actions = [actions]
    else if not actions?
      actions = []
    return actions

  processActions: (actions) ->
    return ActionProcessor.process(@, actions, @abilities)

  emitActive: (action, data...) ->
    @emitSocket @model.state.activePlayer, action, data...

  emitActionsActive: (event, actions) ->
    @emitSocket @model.state.activePlayer, event, @sanitizePayloads(@model.state.activePlayer, actions)

  emitSocket: (userId, action, data...) ->
    if @sockets[userId]?
      @sockets[userId].emit action, data...

  emitActionsAllButActive: (event, actions) ->
    @emitActionsAllBut @model.state.activePlayer, event, actions

  emitAllButActive: (action, data...) ->
    @emitAllBut @model.state.activePlayer, action, data...

  emitActionsAllBut: (ignore, event, actions) ->
    for userId, socket of @sockets
      if ignore isnt userId
        socket.emit event, @sanitizePayloads(userId, actions)

  emitAllBut: (ignore, action, data...) ->
    for userId, socket of @sockets
      if ignore isnt userId
        socket.emit action, data...

  emitActionsAll: (event, actions) ->
    for userId, socket of @sockets
      socket.emit event, @sanitizePayloads(userId, actions)

  emitAll: (action, data...) ->
    for userId, socket of @sockets
      socket.emit action, data...

  # Called when the game is over and a player has won
  declareWinner: (userId) ->
    @model.state.phase = 'over'
    @model.winner = userId
    losers = (userId for userId, socket of @sockets).filter (u)-> u isnt userId
    @emit 'battle-over', userId, losers

  virtualPlayout: (turnLimit, cb)->
    turnCount = 0
    if @model.isVirtual? and @model.isVirtual
      _doTurnFor = (handler, battleOverCb) =>
        turnCount++
        if turnCount >= turnLimit
          battleOverCb null, null
          #battleOverCb null, @getHighestHealthPlayer()?.userId
        else
          _delayed = => handler.doVirtualTurn => _nextTurn(battleOverCb)
          setTimeout _delayed, 0
      _nextTurn = (battleOverCb) =>
        if @outOfCards()
          battleOverCb null, null
          #battleOverCb null, @getHighestHealthPlayer()?.userId
        else if @model.state.phase is 'over'
          battleOverCb null, @model.winner
        else
          _doTurnFor @getActivePlayerHandler(), battleOverCb
      _nextTurn(cb)
    else
      throw new Error("Virtual playout called on non-virtual battle")

  startGame: ->
    @model.state.phase = 'game'
    @assignNextActivePlayer()

    # Play the heroes for all players
    playHero = (handler, cb) -> handler.getHeroHandler().play cb
    async.mapSeries (handler for id, handler of @players), playHero, (err, actionSets) =>
      initActions = []
      for actions in actionSets
        initActions = initActions.concat actions

      for i in [0..INITIAL_CARD_COUNT]
        initActions.push new DrawCardAction(@getActivePlayer())
      for p in @getNonActivePlayers()
        for i in [0..(INITIAL_CARD_COUNT-1)]
          initActions.push new DrawCardAction(@getPlayer(p))
      @nextTurn(initActions)

  nextTurn: (initActions)->
    @model.turnNumber++
    # Pick the next player and set to active
    if not initAction?
      @assignNextActivePlayer()
    actions = initActions || []
    actions.push new StartTurnAction(@getActivePlayer())
    payloads = @processActions(actions)
    @emitActive 'your-turn'
    @emitAllButActive 'opponent-turn'
    @emitActionsAll 'action', payloads

    # If it's the bot's turn, then tell the bot to handle its turn
    activePlayer = @getActivePlayer()
    if not @model.isVirtual?
      if activePlayer.isBot
        doTurn = => @getPlayerHandler(activePlayer).doTurn()
        setTimeout doTurn, 0

  sanitizePayloads: (userId, payloads) ->
    out = []
    for payload in payloads
      if payload.player? and payload.player isnt userId and payload.sanitized?
        out.push payload.sanitized
      else
        out.push payload
    return out

  assignNextActivePlayer: ->
    if @model.state.activePlayer?
      @model.state.activePlayer = @getNextPlayer(@model.state.activePlayer).userId
    else
      @model.state.activePlayer = @getRandomPlayer().userId

  getNextPlayer: (userId)->
    idx = @model.users.indexOf(userId)
    if idx is @model.players.length - 1
      idx = 0
    else
      idx++
    return @players[@model.users[idx]]

  getRandomPlayer: ->
    return @model.players[Math.floor(Math.random() * @model.players.length)]

  getActivePlayer: ->
    return @getPlayer(@model.state.activePlayer)

  getActivePlayerHandler: ->
    return @getPlayerHandler(@getActivePlayer())

  getPossibleMoves: (cb)->
    @getActivePlayerHandler().getPossibleMoves cb

  getNonActivePlayerHandler: ->
    return @getPlayerHandler(@getNonActivePlayers()[0])

  getNonActivePlayers: ->
    return @model.users.filter (u) => u isnt @model.state.activePlayer

  getPhase: -> return @model.state.phase

  getPlayer: (playerId) ->
    if typeof playerId is 'object'
      playerId = playerId.userId
    return @getPlayerHandler(playerId).player

  getPlayerHandler: (playerId) ->
    if typeof playerId is 'object'
      if playerId.userId?
        playerId = playerId.userId
      else
        playerId = ''
    return @players[playerId]

  getOtherPlayers: (playerId) ->
    if typeof playerId isnt 'string'
      playerId = playerId._id
    return (p for id, p of @players when id isnt playerId)

  # Get the hero for the player ID
  getHero: (userId) ->
    if typeof userId is 'object' and userId.userId?
      return @getPlayerHandler(userId.userId).getHero()
    player = @getPlayerHandler(userId)
    if player?
      return player.getHero()
    else
      return null

  getHeroes: ->
    heroes = []
    for playerId, player of @players
      heroes.push player.getHero()
    return heroes

  getHeroOfPlayer: (playerId) ->
    playerId = playerId._id if playerId._id?
    return @getHero(playerId)

  # Given an ID, get the hero or card that correspond to it
  getCardOrHero: (id) ->
    if not id?
      return null
    if id._id?
      id = id._id
    hero = @getHero(id)
    if hero?
      return hero
    return @getCard(id)

  getPlayerOf:(objId) ->
    player = @getPlayerOfHero(objId)
    if player?
      return player
    else
      return @getPlayerOfCard(objId)

  getPlayerOfCard: (cardId) ->
    if cardId._id?
      cardId = cardId._id
    for _, p of @players
      card = p.getCard(cardId)
      if card?
        return p.getModel()
    return null

  getPlayerOfHero: (heroId) ->
    if heroId._id?
      heroId = heroId._id
    for _, p of @players
      hero = p.getHero()
      if hero._id.toString() is heroId.toString()
        return hero
    return null

  getCardHandler: (cardId) ->
    if cardId._id?
      cardId = cardId._id
    return @cards[cardId]

  getHeroHandler: (heroId) ->
    player = @getPlayerOfHero(heroId)
    return @getPlayerHandler(player).getHeroHandler()

  getCard: (cardId) ->
    for _, p of @players
      card = p.getCard(cardId)
      if card?
        return card
    return null

  getFieldCards: (player) ->
    if player?
      if typeof player is 'object'
        if player instanceof PlayerHandler
          return player.getFieldCards()
        else if player.userId?
          return @getPlayerHandler(player.userId).getFieldCards()
      else
        return @getPlayerHandler(player).getFieldCards()
    else
      fieldCards = []
      for _, p of @players
        fieldCards = fieldCards.concat p.getFieldCards()
      return fieldCards
    return null

  sanitizeOpponentData: (player) ->
    out =
      userId: player.getUserId()
      energy: player.getEnergy()
      maxEnergy: player.getMaxEnergy()
      hero: player.getHero() #TODO: Make sure that all hero data is fine for the player to see (secrets and such should be stripped)
      field: player.getFieldCards()
      hand: player.getHandCards().map( (c) -> c._id) # Player does not get to see opponent's cards
      deckSize: player.getDeckCards().length

  getOpponentsData: (user) ->
    others = @model.players.filter (p) -> p.userId isnt user._id.toString()
    return others.map((o) => @sanitizeOpponentData(@players[o.userId]))

  getData: (user) ->
    player = @players[user._id]
    out =
      connectedPlayers: (playerId for playerId, socket of @sockets)
      activePlayer: @model.state.activePlayer
      turnNumber: @model.turnNumber
      state:
        phase:@model.state.phase
      you:
        maxEnergy: player.getMaxEnergy()
        energy: player.getEnergy()
        hero: player.getHero()
        field: player.getFieldCards()
        hand: player.getHandCards()
        deckSize: player.getDeckCards().length # Player doesn't get to know what card is in deck
      opponents: @getOpponentsData(user)

  outOfCards: ->
    for id, playerHandler of @players
      if playerHandler.getFieldCards() isnt 0 or playerHandler.getDeckCards() isnt 0 or playerHandler.getHandCards() isnt 0
        return false
    return true

  getHighestHealthPlayer: ->
    healths = []
    for id, playerHandler of @players
      healths.push {player:id, health:playerHandler.getHeroHandler().getHealth()}
    healths.sort (a, b) -> b.health-a.health
    if healths[0].health is healths[1].health
      return null
    return @getPlayer(healths[0].player)

  getTurnNumber: -> return @model.turnNumber
  # Used to generate unique ability Ids
  getNextAbilityId: ->
    return @model.abilityId++

module.exports = Battle
