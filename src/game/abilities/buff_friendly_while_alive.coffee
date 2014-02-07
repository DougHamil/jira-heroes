AddModifierAction = require '../actions/addmodifier'
RemoveModifierAction = require '../actions/removemodifier'
CastPassiveAction = require '../actions/castpassive'

class BuffFriendlyWhileAlive
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data
    @model.modifierId = @model.modifierId || @model._id
    @buffHero = if @model.data.buffHero? then @model.data.buffHero else false
    @buffSelf = if @model.data.buffSelf? then @model.data.buffSelf else false
    @buffAdded = if @model.data.buffAdded? then @model.data.buffAdded else true

  getValidTargets: -> return null

  # Called when this ability is registered to the battle (ie is now active)
  onRegistered: (battle) ->
    player = battle.getPlayerOfCard(@source)
    actions = []
    for minion in battle.getFieldCards(player)
      if minion isnt @source
        actions.push new AddModifierAction(@model.modifierId, minion, @data)
    if @buffHero
      for hero in battle.getHeroes()
        if hero isnt @source
          actions.push new AddModifierAction(@model.modifierId, hero, @data)
    return actions

  respond: (battle, payloads, actions) ->
    player = battle.getPlayerOfCard(@source)

    # Buff any played cards
    if @buffAdded
      for payload in payloads
        if payload.type is 'play-card' and payload.player is player.userId and payload.card isnt @source
          subActions = []
          subActions.push new AddModifierAction(@model.modifierId, payload.card, @data)
          actions.push new CastPassiveAction(@source, payload.card, subActions, 'buff')
          return true
    return false

  # Called when this ability is unregistered from the battle (ie is now inactive)
  onUnregistered: (battle) ->
    player = battle.getPlayerOfCard(@source)
    actions = []
    for minion in battle.getFieldCards()
      if minion.hasModifier(@model.modifierId)
        actions.push new RemoveModifierAction(@model.modifierId, minion)
      else
        console.log "Minion no have modifier"
    for hero in battle.getHeroes()
      if hero.hasModifier(@model.modifierId)
        actions.push new RemoveModifierAction(@model.modifierId, hero)
    return actions

module.exports = BuffFriendlyWhileAlive
