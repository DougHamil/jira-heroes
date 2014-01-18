class RefillEnergyAction
  constructor: (@player) ->

  enact: (battle) ->
    amount = @player.maxEnergy - @player.energy
    if amount < 0
      amount = 0
    @player.energy += amount
    PAYLOAD =
      type: 'energy'
      player: @player.userId
      amount: amount
    return [PAYLOAD]

module.exports = RefillEnergyAction
