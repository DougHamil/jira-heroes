PermStatusAddAction = require './permstatusadd'

class AttackAction
  constructor: (@source, @target) ->

  enact: (battle)->
    actions = []
    if 'used' not in @source.getStatus()
      actions.push new PermStatusAddAction(@source, 'used')
    PAYLOAD =
      type: 'attack'
      source: @source._id
      target: @target._id
    return [PAYLOAD, actions]

module.exports = AttackAction
