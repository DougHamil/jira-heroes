CastPassiveAction = require '../../actions/castpassive'
RemoveModifierAction = require '../../actions/removemodifier'
AddModifierAction = require '../../actions/addmodifier'

###
# Sum all friendly minions damage and set it as the current damage of the source
# Used for "Spaghetti Code" hacker minion
###
class SumMinionDamageAbility
  constructor: (@model) ->
    @source = @model.source
    @modId = @model._id

  getValidTargets: -> return null

  _buildModifiers: (minions) ->
    totalDamage = 0
    for minion in minions
      if minion isnt @source
        totalDamage += minion.getDamage()
    return [new RemoveModifierAction(@modId, @source), new AddModifierAction(@modId, @source, {damage:totalDamage})]

  onRegistered: (battle) ->
    player = battle.getPlayerOfCard(@source)
    return @_buildModifiers(battle.getFieldCards(player))

  respond: (battle, payloads, actions) ->
    for payload in payloads
      if ((payload.type is 'spawn-card' or payload.type is 'play-card') and payload.player is @source.userId) or (payload.type is 'discard-card')
        playerHandler = battle.getPlayerHandler(@source.userId)
        minions = playerHandler.getFieldCards()
        subActions = @_buildModifiers(minions)
        if subActions.length > 0
          actions.push new CastPassiveAction(@source, minions, subActions, @model.fx)
        return true
    return false

module.exports = SumMinionDamageAbility
