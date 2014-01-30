PermStatusRemoveAction = require './permstatusremove'

class EndTurnAction
  constructor: (@player) ->

  enact: (battle) ->
    actions = []
    for card in battle.getFieldCards(@player)
      if 'sleeping' in card.status
        actions.push new PermStatusRemoveAction(card, 'sleeping')
      if 'used' in card.status
        actions.push new PermStatusRemoveAction(card, 'used')
    PAYLOAD =
      type: 'end-turn'
      player: @player.userId
    return [PAYLOAD, actions]

module.exports = EndTurnAction
