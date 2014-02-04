async = require 'async'
CardCache = require '../../lib/models/cardcache'
Abilities = require './abilities'
Errors = require './errors'
Actions = require './actions'
Events = require './events'

MAX_FIELD_CARDS = 5

class CardHandler
  constructor: (@battle, @playerHandler, @model) ->
    @cardClass = CardCache.cards[@model.class]
    # Spell cards have a "playAbility" property and do not have an attack ability
    if not @cardClass.playAbility? or not @cardClass.playAbility.class?
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
      try
        actions = [Actions.CastRush(@model, cardClass, target), Actions.AddStatus(@model, 'used')]
        actions = actions.concat(@_castAbilityFromModel(cardClass.rushAbility, target))
        cb null, actions
      catch ex
        cb ex if cb?
        if not ex.jiraHeroesError?
          throw ex
    else
      cb Errors.INVALID_ACTION

  _use: (target, cardClass, cb) ->
    if cardClass.useAbility? and cardClass.useAbility.class?
      try
        actions = @_castAbilityFromModel cardClass.useAbility, target
        cb null, actions
      catch ex
        cb ex if cb?
        if not ex.jiraHeroesError?
          throw ex
    else if @attackAbility?
      try
        actions = @_castAbility @attackAbility, target
        cb null, actions
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
        # Auto-cast rush ability if it doesn't require a target
        if @model.hasRushAbility(cardClass) and not cardClass.rushAbility.requiresTarget
          actions.push Actions.CastRush(@model, cardClass, null)
          actions.push Actions.AddStatus(@model, 'used')
          actions = actions.concat(@_castAbilityFromModel(cardClass.rushAbility, null))
      @model.turnPlayed = @battle.getTurnNumber()
      cb null, actions
    catch err # Abilities can throw errors if their target is invalid
      console.log "Play card error #{cardClass.name}: "
      console.log cardClass.playAbility
      console.log err
      console.log target
      cb err if cb?
      # Throw error higher if this is an actual program error
      if not err.jiraHeroesError?
        throw err

  use: (target, cb) ->
    if target?
      CardCache.get @model.class, (err, cardClass) =>
        validationError = @validateUse target, cardClass
        if validationError? and cb?
          cb validationError
        if not validationError?
          if cardClass.rushAbility? and cardClass.rushAbility.class? and @model.turnPlayed is @battle.getTurnNumber()
            @_useRush target, cardClass, cb
          else
            @_use target, cardClass, cb
    else
      cb Errors.INVALID_TARGET if cb?


  # Determine which targets are valid if this card were to be used
  getValidUseTargets: (cb)->
    if @cardClass.rushAbility? and @cardClass.rushAbility.class? and @model.turnPlayed is @battle.getTurnNumber()
      ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, @cardClass.rushAbility
      targets = ability.getValidTargets(@battle)
      if targets?
        targets = targets.filter (t) => return not @validateUse(t, @cardClass)?
      cb null, targets
    else if @attackAbility?
      targets = @attackAbility.getValidTargets(@battle)
      targets = targets.filter (t) => return not @validateUse(t, @cardClass)?
      cb null, targets
    else
      cb null, []

  # Determine which objects are valid for targetting by this card on play
  getValidPlayTargets: (cb)->
    if @cardClass.isSpellCard() and @cardClass.playAbility.requiresTarget
      ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, @cardClass.playAbility
      targets = ability.getValidTargets(@battle)
      if targets?
        targets = targets.filter (t) => return not @validatePlay(t, @cardClass)?
      cb null, targets
    else
      cb null, null

  validateUse: (target, cardClass) ->
    if 'used' in @model.getStatus()
      return Errors.CARD_USED
    if 'sleeping' in @model.getStatus()
      if not cardClass.rushAbility? or not cardClass.rushAbility.class?
        return Errors.CARD_SLEEPING
      else if @model.turnPlayed < @battle.getTurnNumber()
        return Errors.CARD_SLEEPING
    return null

  validatePlay: (target, cardClass) ->
    if @playerHandler.player.energy < @model.getEnergy()
      return Errors.NOT_ENOUGH_ENERGY
    if not cardClass.isSpellCard() and @playerHandler.getFieldCards().length >= MAX_FIELD_CARDS
      return Errors.FULL_FIELD
    if cardClass.isSpellCard() and cardClass.playAbility.requiresTarget and not target?
      return Errors.INVALID_TARGET

  play: (target, cb) ->
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
