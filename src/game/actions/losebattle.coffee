class LoseBattleAction
  constructor: (@userId) ->

  enact: (battle) ->
    # TODO: Inform the battle to switch phases to summary
    PAYLOAD =
      type: 'lose-battle'
      player:@userId
    return [PAYLOAD]

module.exports = LoseBattleAction
