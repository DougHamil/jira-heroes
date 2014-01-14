module.exports = class HealAction
  constructor: (@source, @target, @amount) ->

  enact: ->
    totalHealed = @target.maxHealth - @target.health
    if totalHealed > @amount
      totalHealed = @amount
    @target.health += totalHealed
    PAYLOAD =
      type: 'heal'
      source: @source._id
      target: @target._id
      amount: totalHealed
    return [PAYLOAD]


