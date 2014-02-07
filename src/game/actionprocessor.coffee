###
# This class is responsible for implementing all of the core
# gameplay-related logic.
###
module.exports = class ActionProcessor

  # Recursively process actions until no more actions are spunoff
  @_process:(battle, actions, payloads, passiveAbilities, depth) ->
    if actions.length <= 0
      return payloads
    else
      # Let all of the passive abilities respond to the actions we wish to process
      # Abilities may add/remove/alter the action list
      for ability in passiveAbilities.filter((a) -> not a.usedFilter)
        # handle method returns true when the ability was invoked
        if ability.filter? and ability.filter(battle, actions)
          ability.used = true

      addedActions = []
      newPayloads = []
      for action in actions
        [payload, newActions] = action.enact(battle)
        if payload?
          if payload instanceof Array
            newPayloads = newPayloads.concat(payload)
            payloads = payloads.concat(payload)
          else
            newPayloads.push payload
            payloads.push payload
        if newActions?
          addedActions = addedActions.concat newActions

      # Now give abilities the chance to respond to payloads
      for ability in passiveAbilities.filter((a) -> not a.usedRespond)
        if ability.respond? and ability.respond(battle, newPayloads, addedActions)
          ability.usedRespond = true
      return @_process battle, addedActions, payloads, passiveAbilities, ++depth

  # Process the provided actions in the context of the provided battle using the
  # provided abilities
  @process:(battle, actions, passiveAbilities) ->
    # Mark all passive abilties as unused
    passiveAbilities.forEach (a) ->
      a.usedRespond = false
      a.usedFilter = false
    # Process actions recurisvely
    return @_process(battle, actions, [], passiveAbilities, 0)
