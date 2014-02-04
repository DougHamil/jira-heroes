async = require 'async'
HeroCache = require '../../lib/models/herocache'
Abilities = require './abilities'
Errors = require './errors'
Actions = require './actions'
Events = require './events'

class HeroHandler
  constructor: (@battle, @playerHandler, @model) ->
    @attackAbility = Abilities.Attack @battle.getNextAbilityId(), @model

  _use: (target, heroClass, cb) ->
    try
      ability = Abilities.NewFromModel @battle.getNextAbilityId(), @model, heroClass.ability
      actions = ability.cast @battle, target
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
    HeroCache.get @model.class, (err, heroClass) =>
      err = @_validateAttack(target, heroClass)
      cb err if cb? and err?
      if not err?
        @_attack target, heroClass, cb

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
    if 'used' in @model.getStatus()
      return Errors.HERO_USED
    if 'frozen' in @model.getStatus()
      return Errors.FROZEN
    if @playerHandler.player.energy < @model.getEnergy()
      return Errors.NOT_ENOUGH_ENERGY
    return null

  _validateAttack: (target, heroClass) ->
    if not target?
      return Errors.INVALID_TARGET
    if 'used' in @model.getStatus()
      return Errors.HERO_USED
    if 'frozen' in @model.getStatus()
      return Errors.FROZEN

    targetCard = @battle.getCard(target.card) if target.card?
    targetHero = @battle.getHero(target.hero) if target.hero?
    if not targetCard? and not targetHero?
      return Errors.INVALID_TARGET
    if targetHero? and targetHero is @model # no attacking self
      return Errors.INVALID_TARGET
    if targetCard? and targetCard.position isnt 'field'
      return Errors.INVALID_TARGET

    # Check for targeting taunt cards
    targetUserId = if targetCard? then targetCard.userId else targetHero.userId
    tauntCards = @battle.getFieldCards(targetUserId).filter (c) -> 'taunt' in c.getStatus() and 'frozen' not in c.getStatus()
    if targetHero? and tauntCards.length isnt 0
      return Errors.MUST_TARGET_TAUNT
    if targetCard? and tauntCards.length isnt 0 and targetCard not in tauntCards
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

module.exports = HeroHandler
