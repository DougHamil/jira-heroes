class EnergyAction
  constructor: (@player, @amount) ->

  enact: (battle) ->
    @player.energy += @amount
    PAYLOAD =
      type: 'energy'
      player: @player.userId
      amount: @amount
    return [PAYLOAD]

module.exports = EnergyAction
