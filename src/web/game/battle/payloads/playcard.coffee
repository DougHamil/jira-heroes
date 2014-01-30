define ['battle/animation', 'util'], (Animation, Util) ->
  class PlayCardPayload
    constructor: (action) ->
      @type = 'play-card'
      @player = action.player
      @card = action.card
      @actions = []

    onAction: (action) -> @actions.push action

    animate: (animator, battle) ->
      battleCard = animator.getBattleCard(@card)
      animation = new Animation()
      for action in @actions
        switch action.type
          when 'energy'
            animation.addUnchainedAnimationStep animator.animateAction(action)
      if @player is battle.getPlayerId()
        animation.addAnimationStep animator.putCardOnField(@card, true)
      else
        animation.addAnimationStep animator.putCardOnEnemyField(@card, true)

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
