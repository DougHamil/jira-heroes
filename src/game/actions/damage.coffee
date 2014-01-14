DestroyAction = require './destroy'

class DamageAction
  constructor: (@source, @target, @damage) ->

  enact: (battle)->
    @target.health -= @damage
    actions = []
    if @target.health <= 0
      actions.push new DestroyAction(@source, @target)

    PAYLOAD =
      type: 'damage'
      source: @source._id
      target: @target._id
      damage: @damage
    return [PAYLOAD, actions]

module.exports = DamageAction
