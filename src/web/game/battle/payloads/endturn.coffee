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
        switch action.type
          when 'status-add'
            animation.addAnimationStep animator.getBattleObject(action.target).animateStatusAdd(action.status)
          when 'status-remove'
            animation.addAnimationStep animator.getBattleObject(action.target).animateStatusRemove(action.status)
          when 'add-modifier'
            animation.addAnimationStep animator.getBattleObject(action.target).animateModifierAdd(action.modifier)
          when 'remove-modifier'
            animation.addAnimationStep animator.getBattleObject(action.target).animateModifierRemove(action.modifier)
      return animation
