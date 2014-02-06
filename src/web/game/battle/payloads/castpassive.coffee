define ['battle/animation', 'util'], (Animation, Util) ->
  class CastPassivePayload
    constructor: (action) ->
      @type = 'cast-passive'
      @source = action.source
      @targets = action.targets
      @name = action.name
      @actions = []

    # Just accumulate actions for now
    onAction: (action) -> @actions.push action

    animate: (animator, battle) ->
      animation = new Animation()

      # Animated any actions that occur after the spell is cast
      for action in @actions
        if action.target?
          animation.addUnchainedAnimationStep animator.getBattleObject(action.target).animateAction(action)

      animation.on 'complete', => animator.animateActions(@actions)

      return animation
