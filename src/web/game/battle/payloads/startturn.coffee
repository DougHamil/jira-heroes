define ['battle/animation', 'util'], (Animation, Util) ->
  class StartTurnPayload
    constructor: (action, battle) ->
      @type = 'start-turn'
      @player = action.player
      @actions = []

    onAction: (action) -> @actions.push action

    animate: (battleAnimator, battle) ->
      animation = new Animation()
      _addDrawAnim = (action) =>
        if action.player is battle.getPlayerId()
          return => battleAnimator.putCardInHand(action.card, true)
        else
          return => battleAnimator.putCardInEnemyHand(action.card, true)

      for action in @actions
        if not action.animated and action.type is 'draw-card'
          action.animated = true
          animation.addAnimationStep _addDrawAnim(action)

      # Animate actions that occur after token has been placed on field
      for action in @actions
        if action.target?
          animation.addUnchainedAnimationStep battleAnimator.getBattleObject(action.target).animateAction(action)

      animation.on 'complete', => battleAnimator.animateActions(@actions)

      return animation
