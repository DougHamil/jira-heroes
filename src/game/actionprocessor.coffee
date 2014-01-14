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
      for ability in passiveAbilities.filter((a) -> not a.used)
        # handle method returns true when the ability was invoked
        if ability.handle(battle, actions)
          ability.used = true

      addedActions = []
      for action in actions
        [payload, newActions] = action.enact(battle)
        if payload?
          if payload instanceof Array
            payloads = payloads.concat(payload)
          else
            payloads.push payload
        if newActions?
          addedActions = addedActions.concat newActions
      return @_process battle, addedActions, payloads, passiveAbilities, ++depth

  # Process the provided actions in the context of the provided battle using the
  # provided abilities
  @process:(battle, actions, passiveAbilities) ->
    # Mark all passive abilties as unused
    passiveAbilities.forEach (a) -> a.used = false
    # Process actions recurisvely
    return @_process(battle, actions, [], passiveAbilities, 0)
