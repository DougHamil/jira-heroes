DrawCardAction = require '../actions/drawcard'

class DrawCardAbility
  constructor: (@model) ->
    @source = @model.sourceCard

  cast: (battle, target) ->
    actions = []
    player = battle.getPlayerOfCard(@source)
    for i in [0...@model.data.amount]
      actions.push new DrawCardAction(player)
    return actions

module.exports = DrawCardAbility
