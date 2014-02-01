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

  validatePlayCard: (cardId, target) ->
    cardHandler = @getCardHandler(cardId)
    if @model.state.phase isnt 'game' or not cardHandler? or not @isActive() or cardHandler.model.position isnt 'hand'
      return Errors.INVALID_ACTION
    return null

  # Validate the use of a card (card attacking some target)
  validateUseCard: (source, target) ->
    if not source? or not target?
      return Errors.INVALID_ACTION
    if @model.state.phase isnt 'game' or not @isActive()
      return Errors.INVALID_ACTION
    cardHandler = @getCardHandler(source)
    if not cardHandler?
      return Errors.INVALID_CARD

    sourceCard = cardHandler.model
    if sourceCard.position isnt 'field' # Only deployed cards can be used
      return Errors.INVALID_ACTION
    if 'frozen' in sourceCard.getStatus() # Frozen cards cannot be used
      return Errors.FROZEN
    targetCard = @battle.getCard(target.card) if target.card?
    targetHero = @battle.getHero(target.hero) if target.hero?
    if not targetCard? and not targetHero? # Player must target something
      return Errors.INVALID_TARGET

    targetUserId = if targetCard? then targetCard.userId else targetHero.userId

    if targetCard? and (targetCard.position isnt 'field' or targetCard is sourceCard) # Target card must be on the field and not the source card
        return Errors.INVALID_TARGET

    tauntCards = @battle.getFieldCards(targetUserId).filter (c)-> 'taunt' in c.getStatus() and 'frozen' not in c.getStatus() # Get non-frozen taunt cards
    if tauntCards.length isnt 0 and targetCard not in tauntCards # If taunt cards are played, then the target must be one of the taunt cards
      return Errors.MUST_TARGET_TAUNT

    # Valid move
    return null

  onUseCard: ->
    (source, target, cb) =>
      err = @validateUseCard(source, target)
      cb err if err? and cb?
      if not err?
        cardHandler = @getCardHandler(source)
        if target.card?
          target = @battle.getCard(target.card)
        else
          target = @battle.getHero(target.hero)
        cardHandler.use target, (useError, actions) =>
          console.log "USE ERROR:"
          console.log useError
          if useError? and cb?
            cb useError
          if not useError?
            @emit Events.USE_CARD, source, target, actions

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
      validationError = @validatePlayCard(cardId, target)
      cb validationError if validationError? and cb?
      if not validationError?
        cardHandler = @getCardHandler(cardId)
        cardHandler.play target, (err, actions) =>
          if err?
            cb err
          else
            @emit Events.PLAY_CARD, cardHandler.model, actions
            cb null, cardHandler.model

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
