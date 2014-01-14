CardStatusRemoveAction = require './cardstatusremove'

module.exports = class EndTurnAction
  constructor: (@player) ->

  enact: (battle) ->
    actions = []
    for card in battle.getFieldCards(@player)
      if 'sleeping' in card.status
        actions.push new CardStatusRemoveAction(card, 'sleeping')
    PAYLOAD =
      type: 'end-turn'
      player: @player.userId
    return [PAYLOAD, actions]
