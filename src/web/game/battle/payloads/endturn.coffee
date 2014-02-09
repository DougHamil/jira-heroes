define ['battle/animation', 'util'], (Animation, Util) ->
  class EndTurnPayload
    constructor: (action) ->
      @type = 'end-turn'
      @player = action.player
      @actions = []

    onAction: (action) ->
      @actions.push action

    animate: (animator, battle) ->
      animation = new Animation()
      # Animate actions that occur after token has been placed on field
      for action in @actions
        if action.target and not action.animated
          animation.addUnchainedAnimationStep animator.getBattleObject(action.target).animateAction(action)
      animation.on 'complete', =>
        animator.animateActions(@actions)
        animator.enqueueAnimation animator.buildReorderAnimations()
      return animation
