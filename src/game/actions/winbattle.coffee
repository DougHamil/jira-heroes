class WinBattleAction
  constructor: (@userId) ->

  enact: (battle) ->
    PAYLOAD =
      type: 'win-battle'
      player: @userId
    return [PAYLOAD]

module.exports = WinBattleAction
