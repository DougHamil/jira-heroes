DrawCardAction = require '../actions/drawcard'
StartTurnAction = require '../actions/startturn'

###
# This ability heals friendly units at the start of the player's turn
###
class StartTurnDrawCardAbility
  constructor: (@model) ->
    @source = @model.source
    @amount = @model.data.amount

  getValidTargets: -> return null

  filter: (battle, actions) ->
    if 'frozen' not in @source.getStatus()
      player = battle.getPlayerOfCard(@source)
      for action in actions
        # Only draw if it's our player's end of turn
        if action instanceof StartTurnAction and player is action.player
          for i in [0...@amount]
            actions.push new DrawCardAction(player)
          return true
    return false

module.exports = StartTurnDrawCardAbility
