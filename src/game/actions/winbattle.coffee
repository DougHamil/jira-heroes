class WinBattleAction
  constructor: (@userId) ->

  enact: (battle) ->
    battle.declareWinner(@userId)
    PAYLOAD =
      type: 'win-battle'
      player: @userId
    return [PAYLOAD]

module.exports = WinBattleAction
