{EventEmitter} = require 'events'

class AchievementModule extends EventEmitter
  constructor: ->

  onBattleJoined:(battle) ->
  onBattleLeft:(battle) ->
  disconnect: ->

module.exports = AchievementModule
