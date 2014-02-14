RevealCardAction = require '../../actions/revealcard'
DamageAction = require '../../actions/damage'
Errors = require '../../errors'

###
# Reveal enemy hand card and deal its damage to the enemy hero,
# if the enemy card is a spell card, deal its energy cost back to
# your hero
###
class PenTestAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data

  getValidTargets: (battle) ->
    targets = []
    for otherPlayer in battle.getOtherPlayers(@source.userId)
      otherPlayerHandler = battle.getPlayerHandler(otherPlayer)
      for handCard in otherPlayerHandler.getHandCards()
        targets.push handCard
    return targets

  cast: (battle, target) ->
    if not target? or not target.isCard
      throw Errors.INVALID_TARGET
    targetCardClass = battle.getCardClass(target)
    actions = [new RevealCardAction(target)]

    # Spell cards deal energy worth of damage back to the player
    if targetCardClass.isSpell()
      actions.push new DamageAction(target, battle.getHeroOfCard(@source), target.getEnergy())
    else
      actions.push new DamageAction(@source, battle.getHeroOfCard(target), target.getDamage())

    return actions

module.exports = PenTestAbility
