CardDrawAction = require './drawcard'
RefillEnergyAction = require './refillenergy'
MaxEnergyAction = require './maxenergy'
CARDS_DRAWN_PER_TURN = 1
ENERGY_INCREASE_PER_TURN = 1
MAX_ENERGY = 10
MAX_HAND_CARDS = 6

class StartTurnAction
  constructor: (@player) ->

  enact: (battle) ->
    playerHandler = battle.getPlayerHandler(@player)
    actions = []
    # Cap the number of cards in a player's hand
    numCardsToDraw = MAX_HAND_CARDS - playerHander.getHandCards().length
    if numCardsToDraw < 0
      numCardsToDraw = 0
    if numCardsToDraw > CARDS_DRAWN_PER_TURN
      numCardsToDraw = CARDS_DRAWN_PER_TURN
    # On start of turn, draw x cards and increase energy by y units
    for i in [1..numCardsToDraw]
      actions.push new CardDrawAction(@player)
    energyIncrease = 0
    if playerHandler.getMaxEnergy() < MAX_ENERGY
      energyIncrease = MAX_ENERGY - playerHandler.getMaxEnergy()
    if energyIncrease > ENERGY_INCREASE_PER_TURN
      energyIncrease = ENERGY_INCREASE_PER_TURN
    if energyIncrease > 0
      actions.push new MaxEnergyAction(@player, ENERGY_INCREASE_PER_TURN)
    actions.push new RefillEnergyAction(@player)

    PAYLOAD =
      type:'start-turn'
      player:@player.userId
    return [PAYLOAD, actions]

module.exports = StartTurnAction
