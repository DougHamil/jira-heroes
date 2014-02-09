define ['battle/fx/factory', 'battle/animation', 'util', 'engine'], (FxFactory, Animation, Util, engine) ->
  class CastCardPayload
    constructor: (action) ->
      @type = 'cast-card'
      @player = action.player
      @source = action.card
      @card = action.card
      @targets = action.targets
      @actions = []

    onAction: (action) -> @actions.push action

    animate: (animator, battle) ->
      animation = new Animation()
      # If the card is the enemy's then we need to reveal it
      if @player isnt battle.getPlayerId()
        battleCard = animator.getBattleCard @card
        animation.addAnimationStep battleCard.moveFlippedCardAndTokenTo({x:engine.WIDTH/2, y:engine.HEIGHT/2 - 200}, 500, false)
        animation.addAnimationStep battleCard.flipCard()
        animation.addPauseStep 500

      cardClass = animator.getCardClass(@card)

      fx = @_buildFx(cardClass)
      animation.addAnimationStep fx.animate(animator)

      animation.addAnimationStep animator.getBattleCard(@card).animateCasted()

      # Animated any actions that occur after the spell is cast
      for action in @actions
        if action.target?
          animation.addUnchainedAnimationStep animator.getBattleObject(action.target).animateAction(action)

      animation.on 'complete', => animator.animateActions(@actions)

      return animation

    _buildFx: (cardClass) ->
      fx = null
      if cardClass.media.fx? and cardClass.media.fx.type?
        fx = FxFactory.create cardClass.media.fx.type, @source, @targets, cardClass.media.fx.data
      else
        fx = FxFactory.create 'cast', @source, @targets, cardClass.media.fx?.data
      return fx
