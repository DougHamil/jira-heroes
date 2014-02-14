DestroyAction = require '../actions/destroy'
CastPassiveAction = require '../actions/castpassive'

###
# This ability spawns another card upon death of the source minion
###
class SpawnOnDeathAbility
  constructor: (@model) ->
    @numberToSpawn = @model.data.count
    @cardName = @model.data.card
    @sourceModel = @model.source

  getValidTargets: -> return null

  filter: (battle, actions) ->
    for action in actions
      if action instanceof DestroyAction and action.target is @sourceModel
        subActions = [battle.createSpawnCardAction(@sourceModel.userId, @cardName)]
        actions.push new CastPassiveAction(@sourceModel, null, subActions, @model.fx)
        return true
    return false

module.exports = SpawnOnDeathAbility
