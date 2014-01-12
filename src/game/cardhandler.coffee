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
      @attackAbility = Abilities.attack @battle, @
    else
      @attackAbility = null

  _castAbility: (ability, target) ->
    target = @_getHeroOrCard(target)
    actions = ability.cast target
    actions = @battle.filterActions actions
    return actions

  _castAbilityFromModel: (abilityModel, target) ->
    ability = Abilities.fromType abilityModel.type, @battle, @, abilityModel.data
    return @_castAbility ability, target

  _useRush: (target, cardClass, cb) ->
    @model.usedRushAbility = true
    if cardClass.rushAbility?
      cb null, @_castAbilityFromModel cardClass.rushAbility, target
    else
      cb Errors.INVALID_ACTION

  _use: (target, cardClass, cb) ->
    if cardClass.useAbility?
      cb null, @_castAbilityFromModel cardClass.useAbility, target
    else if @attackAbility?
      cb null, @_castAbility @attackAbility, target
    else
      cb Errors.INVALID_ACTION

  _play: (target, cardClass, cb) ->
    @playerHandler.player.energy -= cardClass.energy
    @model.used = false
    @model.usedRushAbility = false

    # Create passive ability objects
    @passiveAbilities = []
    for ability in cardClass.passiveAbilities
      ability = Abilities.fromType ability.type, @battle, @, ability.data
      @passiveAbility.push ability

    actions = []
    if cardClass.playAbility?
      actions = @_castAbilityFromModel cardClass.playAbility, target
      # Spell cards are always discarded
      actions.push Actions.DiscardCard @model
    else
      actions.push Actions.PlayCard @model, cardClass
    actions = @battle.filterActions actions
    cb null, @battle.processActions(actions)

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
      if STATUS.SLEEPING in @model.status or @model.used
        cb Errors.CARD_SLEEPING, null
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
    for ability in @passiveAbilities
      @battle.registerAbility ability

  unregisterPassiveAbilities: ->
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
