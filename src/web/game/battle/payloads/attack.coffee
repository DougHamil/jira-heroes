define ['battle/animation', 'battle/fx/factory', 'util'], (Animation, FxFactory, Util) ->
  class AttackPayload
    constructor: (attackAction) ->
      @type = 'attack'
      @source = attackAction.source
      @target = attackAction.target
      @sourceDamage = 0
      @targetDamage = 0
      @sourceDestroyed = false
      @targetDestroyed = false
      @actions = []

    onAction: (action) ->
      if action.type is 'damage'
        if action.target is @source
          @sourceDamage += action.damage
        else if action.target is @target
          @targetDamage += action.damage
      else if action.type is 'destroy'
        if action.target is @source
          @sourceDestroyed = true
        else if action.target is @target
          @targetDestroyed = true
      @actions.push action

    animate: (animator, battle) ->
      fxData =
        source: battle.getCardOrHero(@source)
        targets: [battle.getCardOrHero(@target)]
      fx = FxFactory.create 'attack', fxData
      animation = fx.animate(animator)
      battleToken = animator.getBattleObject(@target)
      sourceBattleToken = animator.getBattleObject(@source)
      targetDamageAnimation = new Animation()
      sourceDamageAnimation = new Animation()
      if @targetDamage > 0
        targetDamageAnimation.addAnimationStep battleToken.animateDamaged()
      if @targetDestroyed
        targetDamageAnimation.addAnimationStep battleToken.animateDestroyed()
        targetDamageAnimation.addAnimationStep animator.discardCard(@target)
      if @sourceDamage > 0
        sourceDamageAnimation.addAnimationStep sourceBattleToken.animateDamaged()
      if @sourceDestroyed
        sourceDamageAnimation.addAnimationStep sourceBattleToken.animateDestroyed()
        sourceDamageAnimation.addAnimationStep animator.discardCard(@source)
      animation.addUnchainedAnimationStep targetDamageAnimation
      animation.addUnchainedAnimationStep sourceDamageAnimation

      for action in @actions
        switch action.type
          when 'status-add'
            animation.addUnchainedAnimationStep animator.getBattleObject(action.target).animateStatusAdd(action.status)
          when 'status-remove'
            animation.addUnchainedAnimationStep animator.getBattleObject(action.target).animateStatusRemove(action.status)
          when 'add-modifier'
            animation.addUnchainedAnimationStep animator.getBattleObject(action.target).animateModifierAdd(action.modifier)
          when 'remove-modifier'
            animation.addUnchainedAnimationStep animator.getBattleObject(action.target).animateModifierRemove(action.modifier)

      return animation
