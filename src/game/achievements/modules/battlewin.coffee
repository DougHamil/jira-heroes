AchievementModule = require '../achievementmodule'

TAGS = ['win1', 'win10', 'win50', 'win100']

class BattlesWonAchievement extends AchievementModule
  constructor: (@battle, @playerhandler, @earned, @pending) ->
    for tag in TAGS
