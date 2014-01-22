class BuffEnergyAction
  constructor:(@target, @amount) ->

  enact: (battle) ->
    if @target.energyBuff?
      @target.energyBuff += @amount
      PAYLOAD =
        type:'buff-energy'
        target:@target._id
        amount:@amount
      return [PAYLOAD]
    else
      return []

module.exports = BuffEnergyAction
