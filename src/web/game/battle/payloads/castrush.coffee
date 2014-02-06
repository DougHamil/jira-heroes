define ['battle/fx/factory', 'battle/animation', 'util'], (FxFactory, Animation, Util) ->
  class CastRushPayload
    constructor: (action) ->
      @type = 'cast-rush'
      @player = action.player
      @source = action.card
      @card = action.card
      @targets = action.targets
      @actions = []

    onAction: (action) -> @actions.push action

    animate: (animator, battle) ->
      animation = new Animation()

      cardClass = animator.getCardClass(@card)
      fx = @_buildFx(cardClass)
      animation.addAnimationStep fx.animate(animator)

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
