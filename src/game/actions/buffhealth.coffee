class BuffHealthAction
  constructor:(@target, @amount) ->

  enact: (battle) ->
    @target.maxHealthBuff += @amount
    PAYLOAD =
      type:'buff-health'
      target:@target._id
      amount:@amount
    return [PAYLOAD]

module.exports = BuffHealthAction
