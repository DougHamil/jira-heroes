class MaxEnergyAction
  constructor: (@player, @amount) ->

  enact: (battle) ->
    @player.maxEnergy += @amount
    PAYLOAD =
      type: 'max-energy'
      player: @player.userId
      amount: @amount
    return [PAYLOAD]

module.exports = MaxEnergyAction
