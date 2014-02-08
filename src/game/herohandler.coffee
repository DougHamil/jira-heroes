async = require 'async'
HeroCache = require '../../lib/models/herocache'
Abilities = require './abilities'
Errors = require './errors'
Actions = require './actions'
Events = require './events'

class HeroHandler
  constructor: (@battle, @playerHandler, @model) ->
    @heroClass = HeroCache.heroes[@model.class]
    @attackAbility = Abilities.HeroAttack @battle.getNextAbilityId(), @model

  _use: (target, heroClass, cb) ->
    try
      actions = []
      ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, heroClass.ability
      targets = if target? then [target] else []
      targets = ability.getTargets(@battle, target) if ability.getTargets?
      actions.push Actions.CastHeroAbility @model, @heroClass, targets
      actions = actions.concat(ability.cast(@battle, target))
      cb null, actions
    catch ex
      cb ex if cb?
      if not ex.jiraHeroesError?
        throw ex

  use: (target, cb) ->
    HeroCache.get @model.class, (err, heroClass) =>
      err = @_validateUse(target, heroClass)
      cb err if cb? and err?
      if not err?
        @_use target, heroClass, cb

  _attack: (target, heroClass, cb) ->
    try
      actions = @attackAbility.cast @battle, target
      cb null, actions
    catch ex
      cb ex if cb?
      if not ex.jiraHeroesError?
        throw ex

  attack: (target, cb) ->
    err = @_validateAttack(target, @heroClass)
    if cb? and err?
      cb err
    if not err?
      @_attack target, @heroClass, cb

  # Called by Battle when game starts, register any passive abilities
  play: (cb) ->
    HeroCache.get @model.class, (err, heroClass) =>
      @passiveAbilities = []
      if heroClass.passiveAbilities?
        for abilityModel in heroClass.passiveAbilities
          ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, abilityModel
          @passiveAbilities.push ability
      actions = [Actions.PlayHero(@model, heroClass)]
      cb null, actions

  registerPassiveAbilities: ->
    actions = []
    if @passiveAbilities?
      for ability in @passiveAbilities
        actions = actions.concat(@battle.registerPassiveAbility(ability))
    return actions

  _validateUse: (target, heroClass) ->
    if heroClass.ability.requiresTarget and not target?
      return Errors.INVALID_TARGET
    if 'ability-used' in @model.getStatus()
      return Errors.HERO_ABILITY_USED
    if 'frozen' in @model.getStatus()
      return Errors.FROZEN
    if @playerHandler.player.energy < @model.getAbilityEnergy()
      return Errors.NOT_ENOUGH_ENERGY
    return null

  _validateAttack: (target, heroClass) ->
    if not target?
      return Errors.INVALID_TARGET
    if 'used' in @model.getStatus()
      return Errors.HERO_USED
    if 'frozen' in @model.getStatus()
      return Errors.FROZEN

    if target is @model # no attacking self
      return Errors.INVALID_TARGET
    if target.isCard and target.position isnt 'field'
      return Errors.INVALID_TARGET

    # Check for targeting taunt cards
    targetUserId = target.userId
    tauntCards = @battle.getFieldCards(targetUserId).filter (c) -> 'taunt' in c.getStatus() and 'frozen' not in c.getStatus()
    if target.isHero and tauntCards.length isnt 0
      return Errors.MUST_TARGET_TAUNT
    if target.isCard and tauntCards.length isnt 0 and target not in tauntCards
      return Errors.MUST_TARGET_TAUNT
    if @model.getDamage() <= 0
      return Errors.NO_DAMAGE
    return null

  # Determine which targets are valid if this card were to be used
  getValidUseTargets: (cb)->
    HeroCache.get @model.class, (err, heroClass) =>
      if heroClass.ability?
        ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, heroClass.ability
        targets = ability.getValidTargets(@battle)
        if targets?
          targets = targets.filter (t) => return not @_validateUse(t, heroClass)?
        cb err, targets
      else
        cb null, []

  # Determine which objects are valid for targetting by this card on play
  getValidAttackTargets: (cb)->
    HeroCache.get @model.class, (err, heroClass) =>
      if @attackAbility? and @model.getDamage() > 0
        targets = @attackAbility.getValidTargets(@battle)
        if targets?
          targets = targets.filter (t) => return not @_validateAttack(t, heroClass)?
        cb err, targets
      else
        cb err, []

  getHealth: -> return @model.health

module.exports = HeroHandler
