async = require 'async'
CardCache = require '../../lib/models/cardcache'
Abilities = require './abilities'
Errors = require './errors'
Actions = require './actions'
Events = require './events'

MAX_FIELD_CARDS = 5

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
      @attackAbility = Abilities.Attack @battle.getNextAbilityId(), @model
    else
      @attackAbility = null

  _castAbility: (ability, target) ->
    return ability.cast @battle, target

  _castAbilityFromModel: (abilityModel, target) ->
    ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, abilityModel
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
        ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, cardClass.playAbility
        targets = if target? then [target] else []
        targets = ability.getTargets(@battle, target) if ability.getTargets?
        actions.push Actions.CastCard(@model, cardClass, targets)
        actions = actions.concat(ability.cast(@battle, target))
        # Spell cards are always discarded
        actions.push Actions.DiscardCard @model
      else
        # Create passive ability objects, PlayCardAction will register them with the battle
        @passiveAbilities = []
        for abilityModel in cardClass.passiveAbilities
          ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, abilityModel
          @passiveAbilities.push ability
        actions.push Actions.PlayCard(@model, cardClass)
      cb null, @battle.processActions(actions)
    catch err
      console.log "Ability Cast Error: "
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
      if @playerHandler.player.energy >= @model.getEnergy()
        if cardClass.playAbility.class? or @playerHandler.getFieldCards().length < MAX_FIELD_CARDS
          @_play target, cardClass, cb
        else
          cb Errors.FULL_FIELD if cb?
      else
        cb Errors.NOT_ENOUGH_ENERGY if cb?

  registerPassiveAbilities: ->
    actions = []
    if @passiveAbilities?
      for ability in @passiveAbilities
        actions = actions.concat(@battle.registerPassiveAbility(ability))
    return actions

  unregisterPassiveAbilities: ->
    actions = []
    if @passiveAbilities?
      for ability in @passiveAbilities
        actions = actions.concat(@battle.unregisterPassiveAbility(ability))
    return actions

  discard: ->
    @unregisterPassiveAbilities()

  returnToHand: (cb) ->
    @model.position = POSITION.HAND
    @unregisterPassiveAbilities()

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
