class OverHealAction
  constructor: (@source, @target, @amount) ->

  enact: (battle)->
    # Heal the target by the amount, even if it's above max health
    @target.health += @amount
    PAYLOAD =
      type: 'overheal'
      source: @source._id
      target: @target._id
      amount: @amount
    return [PAYLOAD]

module.exports = OverHealAction
