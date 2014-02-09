define ['battle/animation', 'util'], (Animation, Util) ->
  class StartTurnPayload
    constructor: (action, battle) ->
      @startTurnAction = action
      @type = 'start-turn'
      @player = action.player
      @actions = []

    onAction: (action) -> @actions.push action

    animate: (battleAnimator, battle) ->
      animation = new Animation()

      # Animates the "Your Turn" graphic
      animation.addAnimationStep battleAnimator.animateAction(@startTurnAction)

      _addDrawAnim = (action) =>
        return => battleAnimator.animateAction(action)

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
