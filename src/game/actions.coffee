PlayCardAction = require './actions/playcard'
DiscardCardAction = require './actions/discardcard'
DamageAction = require './actions/damage'

class Actions
  @PlayCard: (cardModel) ->
    return new PlayCardAction(cardModel)
  @DiscardCard: (cardModel) ->
    return new DiscardCardAction(cardModel)
  @Damage: (source, target, damage) ->
    return new DamageAction source, target, damage

  @_heroOrCard: (target) ->
    out = null
    if target.isHero?
      out =
        hero: target._id
    else
      out =
        card: target._id
    return out

module.exports = Actions
