class HealAction
  constructor: (@source, @target, @amount) ->

  enact: (battle)->
    totalHealed = (@target.maxHealth ) - @target.health
    if totalHealed > @amount
      totalHealed = @amount
    if totalHealed < 0
      totalHealed = 0
    @target.health += totalHealed
    PAYLOAD =
      type: 'heal'
      source: @source._id
      target: @target._id
      amount: totalHealed
    return [PAYLOAD]

module.exports = HealAction
