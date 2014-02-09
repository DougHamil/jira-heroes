AddModifierAction = require '../actions/addmodifier'
CastPassiveAction = require '../actions/castpassive'

class BuffAllFriendly
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data
    @model.modifierId = @model.modifierId || @model._id
    @buffAdded = if @model.data.buffAdded? then @model.data.buffAdded else true

  getValidTargets: -> return null

  # Called when this ability is registered to the battle (ie is now active)
  onRegistered: (battle) ->
    player = battle.getPlayerOfCard(@source)
    actions = []
    for minion in battle.getFieldCards(player)
      actions.push new AddModifierAction(@model.modifierId, minion, @data)
    return actions

  # Look for any new minions added to the field and buff them
  respond: (battle, payloads, actions) ->
    if @buffAdded
      player = battle.getPlayerOfCard(@source)
      for payload in payloads
        if payload.type is 'play-card' and payload.player is player.userId and payload.card isnt @source
          subActions = []
          subActions.push new AddModifierAction(@model.modifierId, payload.card, @data)
          actions.push new CastPassiveAction(@source, payload.card, subActions, @model.fx)
          return true
    return false

  # Called when this ability is unregistered from the battle (ie is now inactive)
  onUnregistered: (battle) ->

module.exports = BuffAllFriendly
