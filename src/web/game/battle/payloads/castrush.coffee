define ['battle/fx/factory', 'battle/animation', 'util'], (FxFactory, Animation, Util) ->
  class CastRushPayload
    constructor: (action) ->
      @type = 'cast-rush'
      @player = action.player
      @card = action.card
      @targets = action.targets
      @actions = []

    onAction: (action) ->
      @actions.push action

    animate: (animator, battle) ->
      animation = new Animation()
      for action in @actions
        anim = animator.animateAction(action)
        if anim?
          animation.addUnchainedAnimationStep anim

      # If the card is the enemy's then we need to reveal it
      if @player isnt battle.getPlayerId()
        battleCard = animator.getBattleCard @card
        animation.addAnimationStep battleCard.moveFlippedCardTo({x:400, y:100}, 1000, false)
        animation.addAnimationStep battleCard.flipCard()

      cardClass = animator.getCardClass(@card)
      if cardClass.media.fx? and cardClass.media.fx.type?
        fxData =
          source: @card
          targets:@targets
          data:cardClass.media.fx.data
        fx = FxFactory.create cardClass.media.fx.type, fxData
        animation.addAnimationStep fx.animate(animator)
      else if @targets.length > 0
        fxData =
          source: @card
          targets: @targets
        fx = FxFactory.create 'attack', fxData
        animation.addAnimationStep fx.animate(animator)

      # Handle all of the possible actions
      subAnimations = {}
      for action in @actions
        subAnim = subAnimations[action.type]
        subAnim = new Animation() if not subAnim?
        subAnimations[action.type] = subAnim
        switch action.type
          when 'draw-card'
            if @player is battle.getPlayerId()
              animation.addAnimationStep animator.putCardInHand(action.card, true)
            else
              animation.addAnimationStep animator.putCardInEnemyHand(action.card, true)
          when 'damage'
            if action.damage > 0
              tToken = animator.getBattleObject(action.target)
              subAnim.addAnimationStep tToken.animateDamaged()
          when 'heal'
            if action.amount > 0
              tToken = animator.getBattleObject(action.target)
              subAnim.addAnimationStep tToken.animateHealed()
          when 'overheal'
            if action.amount > 0
              tToken = animator.getBattleObject(action.target)
              subAnim.addAnimationStep tToken.animateHealed()
          when 'destroy'
            tToken = animator.getBattleObject(action.target)
            subAnim.addAnimationStep tToken.animateDestroyed()
            subAnim.addAnimationStep animator.discardCard(action.target)
          when 'status-add'
            subAnim.addAnimationStep animator.getBattleObject(action.target).animateStatusAdd(action.status)
          when 'status-remove'
            subAnim.addAnimationStep animator.getBattleObject(action.target).animateStatusRemove(action.status)
          when 'add-modifier'
            subAnim.addAnimationStep animator.getBattleObject(action.target).animateModifierAdd(action.modifier)
          when 'remove-modifier'
            subAnim.addAnimationStep animator.getBattleObject(action.target).animateModifierRemove(action.modifier)
      for key, anim of subAnimations
        animation.addUnchainedAnimationStep anim
      animation.addAnimationStep animator.getBattleCard(@card).animateCasted()
      animation.addAnimationStep animator.discardCard(@card)
      return animation
