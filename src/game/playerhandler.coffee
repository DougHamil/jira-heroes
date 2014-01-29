{EventEmitter} = require 'events'
EndTurnAction = require './actions/endturn'
CardCache = require '../../lib/models/cardcache'
CardHandler = require './cardhandler'
Errors = require './errors'
Events = require './events'

MAX_HAND_SIZE = 6

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
            if 'frozen' not in card.getStatus()
              # Card use targeting a card
              if target.card?
                targetCard = @battle.getCard(target.card)
                # Can only target cards on the field and cannot target self
                if targetCard? and targetCard.position is 'field' and targetCard isnt card
                  # If there is a taunt card on the field, then the target must be taunt
                  fieldCards = @battle.getFieldCards(targetCard.userId)
                  fieldCards = fieldCards.filter (c) -> 'taunt' in c.getStatus() and 'frozen' not in c.getStatus()
                  if fieldCards.length is 0 or targetCard in fieldCards
                    cardHandler.use targetCard, (err, actions) =>
                      cb err if cb?
                      if not err?
                        @emit Events.USE_CARD, card, targetCard, actions
                  else
                    cb Errors.MUST_TARGET_TAUNT if cb?
                else
                  cb Errors.INVALID_TARGET if cb?
              # Card use targeting a hero
              else if target.hero?
                hero = @battle.getHero(target.hero)
                if hero?
                  # If a taunt card is deployed, then you must target the taunt first
                  fieldCards = @battle.getFieldCards(hero.userId).filter (c) -> 'taunt' in c.getStatus() and 'frozen' not in c.getStatus()
                  if fieldCards.length is 0
                    cardHandler.use hero, (err, actions) =>
                      cb err if cb?
                      if not err?
                        @emit Events.USE_CARD, card, hero, actions
                  else
                    cb Errors.MUST_TARGET_TAUNT if cb?
                else
                  cb Errors.INVALID_TARGET if cb?
              else
                cb Errors.INVALID_ACTION if cb?
            else
              cb Errors.FROZEN if cb?
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
        cb null if cb?
      else
        cb Errors.INVALID_ACTION if cb?

  onPlayCard: ->
    (cardId, target, cb) =>
      cardHandler = @getCardHandler(cardId)
      if @model.state.phase is 'game' and cardHandler? and @isActive() and cardHandler.model.position is 'hand'
        cardHandler.play target, (err, actions) =>
          if err?
            cb err
          else
            @emit Events.PLAY_CARD, cardHandler.model, actions
            cb null, cardHandler.model
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

  ###
  # Called by DrawCardAction to draw a single card
  ###
  drawCard: ->
    deck = @getDeckCards()
    if deck.length is 0
      return null
    else
      card = deck[Math.floor(Math.random() * deck.length)]
      card.position = 'hand'
      return card

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

  getMaxEnergy: -> return @player.maxEnergy
  getEnergy: -> return @player.energy
  getUserId: -> return @player.userId
  getDeck: -> return @player.deck
  getHero: -> return @player.deck.hero
  getModel: -> return @player
  getMaxHandSize: -> return MAX_HAND_SIZE

  hasCard: (cardId) ->
    return (@player.deck.cards.filter (c) -> c._id is cardId).length > 0

  isCardInHand: (cardId) ->
    return cardId in (@getHandCards().map -> (c) -> c._id)

  isActive: ->
    return @model.state.activePlayer is @userId

module.exports = PlayerHandler
