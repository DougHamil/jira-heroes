define ['battle/animation', 'util', 'engine'], (Animation, Util, engine) ->
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

      # If the card is the enemy's then we need to reveal it
      if @player isnt battle.getPlayerId()
        battleCard = animator.getBattleCard @card
        animation.addAnimationStep battleCard.moveFlippedCardAndTokenTo({x:engine.WIDTH/2, y:engine.HEIGHT/2 - 200}, 500, false)
        animation.addAnimationStep battleCard.flipCard()
        animation.addPauseStep 500

      if @player is battle.getPlayerId()
        animation.addAnimationStep => animator.putCardOnField(@card, true)
      else
        animation.addAnimationStep => animator.putCardOnEnemyField(@card, true)

      # Animate actions that occur after token has been placed on field
      for action in @actions
        if action.target?
          animation.addUnchainedAnimationStep animator.getBattleObject(action.target).animateAction(action)

      animation.on 'complete', => animator.animateActions(@actions)
      return animation
