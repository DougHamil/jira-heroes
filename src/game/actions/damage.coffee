DestroyAction = require './destroy'

class DamageAction
  constructor: (@source, @target, @damage) ->

  enact: ->
    @target.health -= @damage
    actions = []
    # If health is below zero, then we spawn a new destroy action
    if @target.health < 0
      actions.push new DestroyAction(@source, @target)
    PAYLOAD =
      type: 'damage'
      source: @source
      target: @target
      damage: @damage
    return [PAYLOAD, actions]

module.exports = DamageAction
