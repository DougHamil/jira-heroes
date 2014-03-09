{EventEmitter} = require 'events'

###
# Hooks to events emitted by the battle and the player handler for user
# and updates achivement statuses based on specific events
###
class AchievementTracker extends EventEmitter
  constructor: (@battle, @playerhandler, @user) ->
    @achievements = @user.achievements


module.exports = AchievementTracker
