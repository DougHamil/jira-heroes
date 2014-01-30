define ['battle/animation', 'util'], (Animation, Util) ->
  class StartTurnPayload
    constructor: (action, battle) ->
      @type = 'start-turn'
      @player = action.player
      @maxEnergyIncrease = 0
      @energyIncrease = 0
      @drawnCards = []
      @enemyDrawnCards = []
      @actions = []

    onAction: (action) ->
      switch action.type
        when 'max-energy'
          @maxEnergyIncrease += action.amount
        when 'energy'
          @energyIncrease += action.amount
        when 'draw-card'
          if action.player is @player
            @drawnCards.push action.card
          else
            @enemyDrawnCards.push action.card
      @actions.push action

    animate: (battleAnimator, battle) ->
      animation = new Animation()
      for card in @drawnCards
        if @player is battle.getPlayerId()
          animation.addAnimationStep battleAnimator.putCardInHand(card, true), 'draw-card'
        else
          animation.addAnimationStep battleAnimator.putCardInEnemyHand(card, true), 'enemy-draw-card'
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
