define ['battle/animation', 'battle/fx/factory', 'util'], (Animation, FxFactory, Util) ->
  class AttackPayload
    constructor: (attackAction) ->
      @type = 'attack'
      @source = attackAction.source
      @target = attackAction.target
      @actions = []
      @actionsById = {}
      @sourceDamageById = {}

    onAction: (action) ->
      if action.target?
        if not @actionsById[action.target]?
          @actionsById[action.target] = []
        @actionsById[action.target].push action
        if action.target is @source
          if not @sourceDamageById[action.source]?
            @sourceDamageById[action.source] = []
          @sourceDamageById[action.source].push action
      @actions.push action

    animate: (animator, battle) ->
      fxData = {}
      fx = FxFactory.create 'attack', @source, @target, fxData
      animation = fx.animate(animator)
      animation.on 'hit-target', (target) =>
        actions = @actionsById[target]
        if actions?
          # Only animate the damage animation on hit
          hitActions = actions.filter (a) -> a.type is 'damage'
          hitActions.forEach (a) -> a.animated = true
          # Usually there should be only one damage action, but if there are more, then consolidate
          hitAction = hitActions[0]
          if hitActions.length > 0
            for i in [1...hitActions.length]
              hitAction.damage += hitActions[i]
            animator.getBattleObject(target).animateAction(hitAction).play()
        # Animate return damage
        actions = @sourceDamageById[target]
        if actions?
          # Only animate the damage animation on hit
          hitActions = actions.filter (a) -> a.type is 'damage'
          hitActions.forEach (a) -> a.animated = true
          # Usually there should be only one damage action, but if there are more, then consolidate
          hitAction = hitActions[0]
          if hitActions.length > 0
            for i in [1...hitActions.length]
              hitAction.damage += hitActions[i]
            animator.getBattleObject(@source).animateAction(hitAction).play()

      animation.on 'complete', => animator.animateActions @actions

      return animation

