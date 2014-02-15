CastPassiveAction = require '../../actions/castpassive'
DamageAction = require '../../actions/damage'
Errors = require '../../errors'

###
# Duplicate one of your minions and give both half health
###
class DuplicateMinionAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data

  getValidTargets: (battle) ->
    return battle.getPlayerHandler(@source.userId).getFieldCards()

  cast: (battle, target) ->
    if not target? or not target.isCard or target.userId isnt @source.userId
      throw Errors.INVALID_TARGET
    targetCardClass = battle.getCardClass(target)
    spawnAction = battle.createSpawnCardAction(@source.userId, targetCardClass.name)
    spawnedCard = spawnAction.cardModel
    spawnedCard.health = target.health/2
    if spawnedCard.health < 1
      spawnedCard.health = 1
    spawnedCard.health = Math.floor(spawnedCard.health)
    subActions = [spawnAction]
    if target.health > spawnedCard.health
      subActions.push new DamageAction(@source, target, target.health - spawnedCard.health)
    return subActions

module.exports = DuplicateMinionAbility
