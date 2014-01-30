define ['util'], (Util) ->
  class CastPassivePayload
    constructor: (action) ->
      @type = 'cast-passive'
      @source = action.source
      @targets = action.targets
      @name = action.name
      @actions = []

    # Just accumulate actions for now
    onAction: (action) ->
      @actions.push action
