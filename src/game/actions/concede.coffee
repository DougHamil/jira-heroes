WinBattleAction = require './winbattle'
LoseBattleAction = require './losebattle'

class ConcedeAction
  constructor: (@source) ->

  enact: (battle) ->
    actions = [new LoseBattleAction(@source.userId)]
    for playerHandler in battle.getOtherPlayers(@source)
      actions.push new WinBattleAction(playerHandler.player)

    PAYLOAD =
      type: 'concede'
      player: @source.userId
    return [PAYLOAD, actions]

module.exports = ConcedeAction
