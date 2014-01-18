CardDrawAction = require './drawcard'
RefillEnergyAction = require './refillenergy'
MaxEnergyAction = require './maxenergy'
CARDS_DRAWN_PER_TURN = 1
ENERGY_INCREASE_PER_TURN = 1

class StartTurnAction
  constructor: (@player) ->

  enact: (battle) ->
    playerHandler = battle.getPlayerHandler(@player)

    actions = []
    # On start of turn, draw x cards and increase energy by y units
    for i in [0..CARDS_DRAWN_PER_TURN]
      actions.push new CardDrawAction(@player)
    actions.push new MaxEnergyAction(@player, ENERGY_INCREASE_PER_TURN)
    actions.push new RefillEnergyAction(@player)

    PAYLOAD =
      type:'start-turn'
      player:@player.userId
    return [PAYLOAD, actions]

module.exports = StartTurnAction
