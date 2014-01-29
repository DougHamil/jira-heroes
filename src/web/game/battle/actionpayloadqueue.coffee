define ['util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  class AttackPayload
    constructor: (attackAction) ->
      @source = attackAction.source
      @target = attackAction.target
      @sourceDamage = 0
      @targetDamage = 0
      @sourceDestroyed = false
      @targetDestroyed = false

    onAction: (action) ->
      if action.type is 'damage'
        if action.target is @source
          @sourceDamage += action.damage
        else if action.target is @target
          @targetDamage += action.damage
        return true
      else if action.type is 'destroy'
        if action.target is @source
          @sourceDestroyed = true
        else if action.target is @target
          @targetDestroyed = true
        return true
      return false
  ###
  # This class consolidates an ordered list of actions into final payloads that can be presented by the UI
  # An example would be aggregating a card attacking another card with final damage output and health
  ###
  class ActionPayloadQueue
    constructor: ->

    processActions:(battle, actions) ->
      payloads = []
      while actions.length > 0
        @processNext(battle, actions, payloads)
      return payloads

    processNext:(battle, actions, payloads) ->
      action = actions.shift()
      switch action.type
        when 'draw-card'
          payloads.push action
        when 'play-card'
          payloads.push action
        when 'cast-card'
          payloads.push action
        when 'attack'
          attackPayload = new AttackPayload(action)
          @processPayload(attackPayload, actionList)
          payloads.push attackPayload

    processPayload: (payload, actions) ->
      if actions.length > 0
        while actions.length > 0
          next = actions.shift()
          if payload.onAction(next)
            next = actions.shift()
          else
            actions.unshift next
            break
      return

