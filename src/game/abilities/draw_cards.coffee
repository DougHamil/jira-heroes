DrawCardAction = require '../actions/drawcard'

class DrawCardAbility
  constructor: (@model) ->
    @source = @model.sourceCard

  getValidTargets: -> return null

  cast: (battle, target) ->
    actions = []
    player = battle.getPlayerOfCard(@source)
    for i in [0...@model.data.amount]
      actions.push new DrawCardAction(player, -1) # -1 reduces the player's hand count by 1 when calculating how many cards are drawn
    return actions

module.exports = DrawCardAbility
