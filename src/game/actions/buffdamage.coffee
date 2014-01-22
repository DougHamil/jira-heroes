class BuffDamageAction
  constructor:(@target, @amount) ->

  enact: (battle) ->
    @target.damageBuff += @amount
    PAYLOAD =
      type:'buff-damage'
      target:@target._id
      amount:@amount
    return [PAYLOAD]

module.exports = BuffDamageAction
