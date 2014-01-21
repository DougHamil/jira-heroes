async = require 'async'
CardCache = require '../../lib/models/cardcache'
Abilities = require './abilities'
Errors = require './errors'
Actions = require './actions'
Events = require './events'

TRAIT =
  RUSH: 'rush'
  TAUNT: 'taunt'

STATUS =
  SLEEPING: 'sleeping'
  TAUNT: 'taunt'

TYPE =
  SPELL: 'spell'
  MINION: 'minion'

POSITION =
  DECK: 'deck'
  HAND: 'hand'
  FIELD: 'field'
  DISCARD: 'discard'

class CardHandler
  constructor: (@battle, @playerHandler, @model) ->
    @cardClass = null
    # Spell cards have a "playAbility" property and do not have an attack ability
    if not @model.playAbility?
      @attackAbility = Abilities.Attack @model
    else
      @attackAbility = null

  _castAbility: (ability, target) ->
    return ability.cast @battle, target

  _castAbilityFromModel: (abilityModel, target) ->
    ability = Abilities.New abilityModel.class, @model, abilityModel.data
    return @_castAbility ability, target

  _useRush: (target, cardClass, cb) ->
    @model.usedRushAbility = true
    if cardClass.rushAbility?
      cb null, @_castAbilityFromModel cardClass.rushAbility, target
    else
      cb Errors.INVALID_ACTION

  _use: (target, cardClass, cb) ->
    if cardClass.useAbility.class?
      try
        actions = @_castAbilityFromModel cardClass.useAbility, target
        cb null, @battle.processActions(actions)
        @model.used = true
      catch ex
        cb ex
    else if @attackAbility?
      try
        actions = @_castAbility @attackAbility, target
        cb null, @battle.processActions(actions)
        @model.used = true
      catch ex
        cb ex
    else
      cb Errors.INVALID_ACTION

  _play: (target, cardClass, cb) ->
    try
      @model.used = false
      @model.usedRushAbility = false
      actions = []
      if cardClass.playAbility.class?
        actions.push Actions.CastCard(@model, cardClass)
        actions = actions.concat(@_castAbilityFromModel(cardClass.playAbility, target))
        # Spell cards are always discarded
        actions.push Actions.DiscardCard @model
      else
        # Create passive ability objects, PlayCardAction will register them with the battle
        @passiveAbilities = []
        for ability in cardClass.passiveAbilities
          ability = Abilities.New ability.type, @, ability.data
          @passiveAbilities.push ability
        actions.push Actions.PlayCard(@model, cardClass)
      cb null, @battle.processActions(actions)
    catch err
      console.log err
      cb err
      if not err.jiraHeroesError?
        throw err

  useRush: (target, cb) ->
    if target?
      if not @model.usedRushAbility
        CardCache.get @model.class, (err, cardClass) =>
          @_useRush target, cardClass, cb
      else
        cb Errors.INVALID_ACTION
    else
      cb Errors.INVALID_TARGET

  use: (target, cb) ->
    if target?
      # Sleeping cards cannot be used, and cards cannot be used twice in a turn
      if STATUS.SLEEPING in @model.status
        cb Errors.CARD_SLEEPING
      else if @model.used
        cb Errors.CARD_USED
      else
        CardCache.get @model.class, (err, cardClass) =>
          @_use target, cardClass, cb
    else
      cb Errors.INVALID_TARGET

  play: (target, cb) ->
    if target?
      if target.card?
        target = @battle.getCard target.card
      else
        target = @battle.getHero target.hero
    CardCache.get @model.class, (err, cardClass) =>
      if @playerHandler.player.energy >= cardClass.energy
        @_play target, cardClass, cb
      else
        cb Errors.NOT_ENOUGH_ENERGY

  registerPassiveAbilities: ->
    if @passiveAbilities?
      for ability in @passiveAbilities
        @battle.registerAbility ability

  unregisterPassiveAbilities: ->
    if @passiveAbilities?
      for ability in @passiveAbilities
        @battle.unregisterAbility ability

  discard: ->
    @unregisterPassiveAbilities()

  returnToHand: (cb) ->
    @model.position = POSITION.HAND
    @unregisterPassiveAbilities()

  @updateFieldCardsOnTurn: (fieldCards) ->
    # On the next turn, remove the sleeping trait
    for card in fieldCards
      card.status = card.status.filter (t) -> t isnt 'sleeping'
      card.used = false

  _getHeroOrCard: (obj) ->
    if obj.hero?
      return @battle.getHero(obj)
    else if obj.card?
      return @battle.getCard(obj)
    return null

  _isFriendly: (target) ->
    if target.hero?
      return target.hero is @playerHandler.getHero()._id
    else if target.card?
      return @playerHandler.getCard(target.card)?
    return false

module.exports = CardHandler
