CardStatusRemoveAction = require './cardstatusremove'

class EndTurnAction
  constructor: (@player) ->

  enact: (battle) ->
    actions = []
    for card in battle.getFieldCards(@player)
      if 'sleeping' in card.status
        actions.push new CardStatusRemoveAction(card, 'sleeping')
      card.used = false
    PAYLOAD =
      type: 'end-turn'
      player: @player.userId
    return [PAYLOAD, actions]

module.exports = EndTurnAction
