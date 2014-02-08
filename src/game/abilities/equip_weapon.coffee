WeaponEquipAction = require '../actions/weaponequip'
WeaponDestroyAction = require '../actions/weapondestroy'
Errors = require '../errors'

class EquipWeaponAbility
  constructor: (@model) ->
    @source = @model.source
    @data = @model.data
    @weapon = @model.data.weapon

  getValidTargets: (battle)-> return null

  cast: (battle, target) ->
    if target?
      throw Errors.INVALID_TARGET
    actions = []
    if @source.weapon?
      actions.push new WeaponDestroyAction(@source)
    actions.push new WeaponEquipAction(@source, @weapon)
    return actions

module.exports = EquipWeaponAbility
