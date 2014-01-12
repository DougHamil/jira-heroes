CardStatusRemoveAction = require './cardstatusremove'
###
# This action is invoked at the end of each turn
# It should remove all sleeping statuses from field cards
###
module.exports = class EndTurnAction
  constructor: (@player) ->

  enact: (battle) ->
    playerHandler = battle.getPlayer(@player.userId)
    actions = []
    for card in playerHandler.getFieldCards()
      if 'sleeping' in card.status
        actions.push new CardStatusRemoveAction(card, 'sleeping')
    PAYLOAD =
      type: 'end-turn'
      player: @player._id
    return [PAYLOAD, actions]


