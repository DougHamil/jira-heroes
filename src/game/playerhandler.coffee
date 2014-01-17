{EventEmitter} = require 'events'
EndTurnAction = require './actions/endturn'
CardCache = require '../../lib/models/cardcache'
CardHandler = require './cardhandler'
Errors = require './errors'
Events = require './events'

###
# Handles a player within a battle by responding and validating client socket events
# and emitting valid events which the battle can listen to
###
class PlayerHandler extends EventEmitter
  constructor: (@battle, @player) ->
    @model = @battle.model
    @userId = @player.userId

  disconnect: ->
  connect: (@socket) ->
      @socket.on Events.READY, @onReady()
      @socket.on Events.PLAY_CARD, @onPlayCard()
      @socket.on Events.END_TURN, @onEndTurn()
      @socket.on Events.USE_CARD, @onUseCard()
      @socket.on Events.TEST, @onTest()

  onUseCard: ->
    (source, target, cb) =>
      if @model.state.phase == 'game' and @isActive()
        cardHandler = @getCardHandler(source)
        if cardHandler?
          card = cardHandler.model
          # Card must be on field to be used
          if card.position is 'field'
            # Card use targeting a card
            if target.card?
              targetCard = @battle.getCard(target.card)
              # Can only target cards on the field
              if targetCard? and targetCard.position is 'field'
                cardHandler.use targetCard, (err, actions) =>
                  cb err, actions if cb?
                  if not err?
                    @emit Events.USE_CARD, card, targetCard, actions
              else
                cb Errors.INVALID_TARGET if cb?
            # Card use targeting a hero
            else if target.hero?
              hero = @battle.getHero(target.hero)
              if hero?
                cardHandler.use hero, (err, actions) =>
                  cb err, actions if cb?
                  if not err?
                    @emit Events.USE_CARD, card, hero, actions
              else
                cb Errors.INVALID_TARGET if cb?
            else
              cb Errors.INVALID_ACTION if cb?
          else
            cb Errors.INVALID_ACTION if cb?
        else
          cb Errors.INVALID_CARD if cb?
      else
        cb Errors.INVALID_ACTION if cb?

  onEndTurn: ->
    (cb) =>
      if @model.state.phase == 'game' and @isActive()
        actions = [new EndTurnAction(@player)]
        payloads = @battle.processActions actions
        @emit 'end-turn', payloads
        cb null, payloads if cb?
      else
        cb Errors.INVALID_ACTION if cb?

  onPlayCard: ->
    (cardId, target, cb) =>
      cardHandler = @getCardHandler(cardId)
      if @model.state.phase == 'game' and cardHandler? and @isActive() and cardHandler.model.position is 'hand'
        cardHandler.play target, (err, actions) =>
          if err?
            cb err if cb?
          else
            @emit Events.PLAY_CARD, cardHandler.model, actions
            cb null, cardHandler.model, actions if cb?
      else
        cb Errors.INVALID_ACTION if cb?

  onReady: ->
      (cb) =>
        if @model.state.phase == 'initial' and @player.userId not in @model.state.playersReady
          @model.state.playersReady.push @player.userId
          cb null if cb?
          @emit Events.READY
        else
          cb Errors.INVALID_ACTION if cb?

  ###
  # Override properties for automated tests
  ###
  onTest: ->
    (prop, value, cb) =>
      if global.isTest?
        @player[prop] = value
      cb() if cb?

  drawCards: (num) ->
    if not num? then num = 1
    deck = @getDeckCards()
    if deck.length is 0
      return null
    else
      drawnCards = []
      for i in [0..num]
        card = deck[Math.floor(Math.random() * deck.length)]
        card.position = 'hand'
        drawnCards.push card
        deck = deck.filter (c) -> c isnt card
        if deck.length is 0
          return drawnCards
      return drawnCards

  getFieldCards: ->
    return @player.deck.cards.filter (c) -> c.position is 'field'

  getHandCards: ->
    return @player.deck.cards.filter (c) -> c.position is 'hand'

  getDeckCards: ->
    return @player.deck.cards.filter (c) -> c.position is 'deck'

  getTauntCardsOnField: ->
    return @getFieldCards().filter (c) -> 'taunt' in c.status

  getCardHandler: (cardId) ->
    return @battle.getCardHandler(cardId)

  getCard: (cardId) ->
    card = @player.deck.cards.filter (c) ->
      c._id.toString() is cardId.toString()
    if card.length > 0
      return card[0]
    else
      return null

  getEnergy: ->
    return @player.energy

  getDeck: ->
    return @player.deck

  getHero: ->
    return @player.deck.hero

  hasCard: (cardId) ->
    return (@player.deck.cards.filter (c) -> c._id is cardId).length > 0

  isCardInHand: (cardId) ->
    return cardId in (@getHandCards().map -> (c) -> c._id)

  isActive: ->
    return @model.state.activePlayer is @userId

module.exports = PlayerHandler
