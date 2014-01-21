DrawCardAction = require '../actions/drawcard'
EndTurnAction = require '../actions/endturn'

###
# This ability heals friendly units at the end of the player's turn
###
class EndTurnDrawCardAbility
  constructor: (@model) ->
    @sourceCard = @model.sourceCard
    @amount = @model.data.amount

  handle: (battle, actions) ->
    player = battle.getPlayerOfCard(@sourceCard)
    for action in actions
      # Only draw if it's our player's end of turn
      if action instanceof EndTurnAction and player is action.player
        for i in [0...@amount]
          actions.push new DrawCardAction(player)
        break

module.exports = EndTurnDrawCardAbility
