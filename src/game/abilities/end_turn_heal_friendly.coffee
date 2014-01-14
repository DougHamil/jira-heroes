Events = require '../events'
HealAction = require '../actions/heal'
###
# This ability heals friendly units at the end of the player's turn
###
class EndTurnHealFriendly
  constructor: (@source, @data) ->
    @amount = data.amount
    @healHero = data.healHero

  handle: (battle, actions) ->
    for action in actions
      # Only heal if this player's turn is over
      if action instanceof EndTurnAction and battle.getPlayer(@source) is action.player
        for minion in battle.getFieldCards(@source)
          actions.push new HealAction(@cardModel, minion, @amount)
        if @healHero?
          hero = battle.getHero(@source)
          actions.push new HealAction(@cardModel, hero, @amount)

module.exports = EndTurnHealFriendly
