StatusAddAction = require '../actions/statusadd'
RemoveModifierAction = require '../actions/removemodifier'

###
# This ability applies a status to a card and then removes it after x turns
###
class MultiTurnStatusAbility
  constructor: (@model, isRestored) ->
    @status = @model.data.status
    @cardModel = @model.sourceCard
    @model.modifierId = @model.modifierId || @model._id

  cast: (battle, target) ->
    battle.registerPassiveAbility @
    # Track the target ID, so if this ability is persisted it can restored
    @model.targetId = target._id
    return [new StatusAddAction(@model.modifierId, target, @status)]

  respond:(battle, payloads, actions) ->
    target = battle.getCard(@model.targetId)
    player = null
    if not target?
      target = battle.getHero(@model.targetId)
    player = battle.getPlayer(target.userId)

    if player?
      for payload in payloads
        if payload.type is 'end-turn' and payload.player is player.userId
          @model.data.turns -= 1
          if @model.data.turns <= 0
            actions.push new RemoveModifierAction(@model.modifierId, target)
            battle.unregisterPassiveAbility @
          return true
    return false

module.exports = MultiTurnStatusAbility
