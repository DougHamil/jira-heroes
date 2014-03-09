{EventEmitter} = require 'events'

###
# Hooks to events emitted by the battle and the player handler for user
# and updates achivement statuses based on specific events
###
class AchievementTracker extends EventEmitter
  constructor: (@user) ->
    @modules = []
    # Initialize all of the modules for unearned achievements
    for achievement in @user.achievements
      if not achievement.earned
        Mod = require('./modules/'+achievement.module)
        if Mod?
          @modules.push new Mod(@, @user, achievement)

  onBattleJoined: (battle) ->
    for mod in @modules
      mod.onBattleJoined(battle)

  onBattleLeft: (battle)->
    for mod in @modules
      mod.onBattleLeft(battle)

  # Called when a battle is over
  disconnect: ->
    for module in @modules
      module.disconnect()

module.exports = AchievementTracker
