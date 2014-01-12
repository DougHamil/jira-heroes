class DestroyAction
  constructor: (@sourceModel, @targetModel) ->

  enact: (battle) ->
    card = battle.getCardHandler(@targetModel._id)
    hero = null
    if not card?
      hero = battle.getHero @targetModel._id
    PAYLOAD =
      type: 'destroy'
      source: @source
    if card?
      card.discard()
      PAYLOAD.card = @targetModel._id
    else if hero?
      PAYLOAD.hero = @targetModel._id
    return [PAYLOAD]

module.exports = DestroyAction
