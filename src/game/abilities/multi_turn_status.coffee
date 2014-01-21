CardStatusAddAction = require '../actions/cardstatusadd'
CardStatusRemoveAction = require '../actions/cardstatusremove'
EndTurnAction = require '../actions/endturn'

###
# This ability applies a status to a card and then removes it after x turns
###
class MultiTurnStatusAbility
  constructor: (@model, isRestored) ->
    @status = @model.data.status
    @cardModel = @model.sourceCard

  cast: (battle, @target) ->
    battle.registerPassiveAbility @
    return [new CardStatusAddAction(target, @status)]

  handle:(battle, actions) ->
    player = battle.getPlayerOfCard(@target)
    if player?
      # Look for an end turn action
      for action in actions
        if action instanceof EndTurnAction and action.player is player
          @model.data.turns -= 1
          console.log @model.data.turns
          if @model.data.turns <= 0
            actions.push new CardStatusRemoveAction(@target, @status)
            battle.unregisterPassiveAbility @
          break

module.exports = MultiTurnStatusAbility
