CastPassiveAction = require '../../actions/castpassive'
StartTurnAction = require '../../actions/startturn'
CardPropAction = require '../../actions/cardprop'
BoostHealthAction = require '../../actions/boosthealth'
RemoveModifierAction = require '../../actions/removemodifier'
AddModifierAction = require '../../actions/addmodifier'

###
# This is a passive ability of the engineer hero that increases
# minions' strength the longer they are on the board.
###
class EngineerPassiveAbility
  constructor: (@model) ->
    @turnsPerLevel = @model.data.turnsPerLevel
    @damageIncreasePerLevel = @model.data.damageIncrease
    @healthIncreasePerLevel = @model.data.healthIncrease
    @source = @model.source
    @mods = @model.mods
    @modIds = @model.modIds
    if not @mods?
      @mods = {}
      @model.mods = @mods
    if not @modIds?
      @modIds = {}
      @model.modIds = @modIds

  getValidTargets: -> return null

  filter: (battle, actions) ->
    for action in actions
      if action instanceof StartTurnAction and action.player._id.toString() is @source.userId
        currentTurn = battle.getTurnNumber()
        playerHandler = battle.getPlayerHandler(@source.userId)
        subActions = []
        targets = []
        for minion in playerHandler.getFieldCards()
          minionTurn = minion.turnPlayed
          level = Math.floor(((currentTurn - minionTurn)/2) / @turnsPerLevel)
          if level > 0
            minionLevel = minion.properties?.engineerLevel
            if not minionLevel? or level isnt minionLevel
              subActions.push new CardPropAction(minion, 'engineerLevel', level)
              # Check for level up
              if level isnt minionLevel
                @_levelUpMinion(minion, level, subActions)
        if subActions.length > 0
          actions.push new CastPassiveAction(@source, null, subActions, @model.fx)
        return true
    return false

  _levelUpMinion: (minion, level, actions) ->
    # Remove the current mods due to the last level
    currentMods = @mods[minion._id]
    if currentMods?
      for mod in currentMods
        actions.push new RemoveModifierAction(mod._id, minion)

    currentMods = []

    # Add new mods from this level
    if @damageIncreasePerLevel? and @damageIncreasePerLevel > 0
      damage = Math.floor(level * @damageIncreasePerLevel)
      newModId = @modIds[minion._id]
      if not newModId?
        newModId = 0
      else
        newModId++
      actions.push new AddModifierAction(newModId, minion, {damage:damage})
      @modIds[minion._id] = newModId
      currentMods.push {_id:newModId}
    if @healthIncreasePerLevel? and @healthIncreasePerLevel > 0
      health = minion.maxHealth + Math.floor(level * @healthIncreasePerLevel)
      newModId = @modIds[minion._id]
      if not newModId?
        newModId = 0
      else
        newModId++
      actions.push new BoostHealthAction(@source, newModId, minion, health)
      @modIds[minion._id] = newModId
      currentMods.push {_id:newModId}
    @mods[minion._id] = currentMods

module.exports = EngineerPassiveAbility
