async = require 'async'
CardCache = require '../../lib/models/cardcache'
Abilities = require './abilities'
Errors = require './errors'
Actions = require './actions'
Events = require './events'

MAX_FIELD_CARDS = 5

class CardHandler
  constructor: (@battle, @playerHandler, @model) ->
    @cardClass = null
    # Spell cards have a "playAbility" property and do not have an attack ability
    if not @model.playAbility? or not @model.playAbility.class?
      @attackAbility = Abilities.Attack @battle.getNextAbilityId(), @model
    else
      @attackAbility = null

  _castAbility: (ability, target) ->
    return ability.cast @battle, target

  _castAbilityFromModel: (abilityModel, target) ->
    ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, abilityModel
    return @_castAbility ability, target

  _useRush: (target, cardClass, cb) ->
    if cardClass.rushAbility? and cardClass.rushAbility.class?
      actions = @_castAbilityFromModel cardClass.rushAbility, target
      cb null, @battle.processAction(actions)
    else
      cb Errors.INVALID_ACTION

  _use: (target, cardClass, cb) ->
    if cardClass.useAbility.class?
      try
        actions = @_castAbilityFromModel cardClass.useAbility, target
        cb null, @battle.processActions(actions)
      catch ex
        cb ex if cb?
        if not ex.jiraHeroesError?
          throw ex
    else if @attackAbility?
      try
        actions = @_castAbility @attackAbility, target
        cb null, @battle.processActions(actions)
      catch ex
        cb ex if cb?
        if not ex.jiraHeroesError?
          throw ex
    else
      cb Errors.INVALID_ACTION if cb?

  _play: (target, cardClass, cb) ->
    try
      actions = []
      # If this is a spell card, cast the spell
      if cardClass.isSpellCard()
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
    catch err # Abilities can throw errors if their target is invalid
      console.log "Ability Cast Error: "
      console.log err
      cb err if cb?
      # Throw error higher if this is an actual program error
      if not err.jiraHeroesError?
        throw err

  useRush: (target, cb) ->
    # Rush abilities require a target
    if target?
      if 'used' in @model.getStatus()
        cb Errors.CARD_USED if cb?
      else
        CardCache.get @model.class, (err, cardClass) =>
          @_useRush target, cardClass, cb
    else
      cb Errors.INVALID_TARGET if cb?

  use: (target, cb) ->
    if target?
      # Sleeping cards cannot be used, and cards cannot be used twice in a turn
      if 'sleeping' in @model.getStatus()
        cb Errors.CARD_SLEEPING if cb?
      else if 'used' in @model.getStatus()
        cb Errors.CARD_USED if cb?
      else
        CardCache.get @model.class, (err, cardClass) =>
          @_use target, cardClass, cb
    else
      cb Errors.INVALID_TARGET if cb?

  validatePlay: (target, cardClass) ->
    if @playerHandler.player.energy < @model.getEnergy()
      return Errors.NOT_ENOUGH_ENERGY
    if not cardClass.isSpellCard() and @playerHandler.getFieldCards().length >= MAX_FIELD_CARDS
      return Errors.FULL_FIELD

  play: (target, cb) ->
    if target?
      if target.card?
        target = @battle.getCard target.card
      else
        target = @battle.getHero target.hero
    CardCache.get @model.class, (err, cardClass) =>
      validationError = @validatePlay(target, cardClass)
      cb validationError if cb? and validationError?
      if not validationError?
        @_play target, cardClass, cb

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
    @model.position = 'hand'
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
