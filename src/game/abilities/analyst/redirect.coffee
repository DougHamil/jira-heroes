DamageAction = require '../../actions/damage'
CastPassiveAction = require '../../actions/castpassive'

###
# Damage taken by this minion is given to the enemy hero as well
###
class RedirectAbility
  constructor: (@model) ->
    @source = @model.source

  getValidTargets: -> return null

  respond: (battle, payloads, actions) ->
    foundDamage = false
    if 'frozen' not in @source.getStatus()
      for payload in payloads
        if payload.type is 'damage' and payload.target.toString() is @source._id.toString() and payload.damage isnt 0
          subActions = []
          targets = []
          for enemy in battle.getOtherPlayers(battle.getPlayerOfCard(@source))
            enemyHandler = battle.getPlayerHandler(enemy)
            targets.push enemyHandler.getHero()
            subActions.push new DamageAction(@source, enemyHandler.getHero(), payload.damage)
          actions.push new CastPassiveAction(@source, targets, subActions, @model.fx)
          foundDamage = true
    return foundDamage

module.exports = RedirectAbility
