AchievementModule = require '../module'

class BattlesWonAchievement extends AchievementModule
  constructor: (@tracker, @user, @model) ->

  onBattleJoined: (@battle) ->
    @listener = (winnerId) =>
      if winnerId.toString() is @user._id.toString()
        if not @model.data.winCount?
          @model.data.winCount = 0
        @model.data.winCount++
        @model.markModified('data')
        if @model.data.wins <= @model.data.winCount
          @model.earned = true
          @tracker.emit 'achievement-earned', @model
        else
          @tracker.emit 'request-save'
    @battle.on 'battle-over', @listener

  onBattleLeft: ->
    if @battle?
      @battle.removeListener 'battle-over', @listener

  disconnect: ->

module.exports = BattlesWonAchievement
