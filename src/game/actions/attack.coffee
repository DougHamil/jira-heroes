class AttackAction
  constructor: (@source, @target) ->

  enact: (battle)->
    PAYLOAD =
      type: 'attack'
      source: @source._id
      target: @target._id
    return [PAYLOAD]

module.exports = AttackAction
