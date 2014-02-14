CastPassiveAction = require '../../actions/castpassive'
Errors = require '../../errors'

###
# Duplicate an enemy field card, and give it to you with half health
###
class PrototypeAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data

  getValidTargets: (battle) ->
    targets = []
    for otherPlayer in battle.getOtherPlayers(@source.userId)
      otherPlayerHandler = battle.getPlayerHandler(otherPlayer)
      for handCard in otherPlayerHandler.getFieldCards()
        targets.push handCard
    return targets

  cast: (battle, target) ->
    if not target? or not target.isCard
      throw Errors.INVALID_TARGET
    targetCardClass = battle.getCardClass(target)
    spawnAction = battle.createSpawnCardAction(@source.userId, targetCardClass.name)
    spawnedCard = spawnAction.cardModel
    spawnedCard.health = target.health/2
    if spawnedCard.health < 1
      spawnedCard.health = 1
    spawnedCard.health = Math.floor(spawnedCard.health)
    return [new CastPassiveAction(@source, null, [spawnAction], @model.fx)]

module.exports = PrototypeAbility
