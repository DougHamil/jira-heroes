define ['battle/fx/factory','battle/animation', 'util'], (FxFactory, Animation, Util) ->
  class CastPassivePayload
    constructor: (action) ->
      @type = 'cast-passive'
      @source = action.source
      @targets = action.targets
      @name = action.name
      @actions = []

    # Just accumulate actions for now
    onAction: (action) -> @actions.push action

    animate: (animator, battle) ->
      animation = new Animation()

      fx = @_buildFx(animator.getCardClass(@source))
      if fx?
        animation.addAnimationStep fx.animate(animator)

      # Animated any actions that occur after the spell is cast
      for action in @actions
        if action.target?
          animation.addAnimationStep animator.getBattleObject(action.target).animateAction(action)

      animation.on 'complete', => animator.animateActions(@actions)

      return animation

    _buildFx: (cardClass) ->
      if not cardClass?
        return null
      fx = null
      if cardClass.media.fx? and cardClass.media.fx.type?
        fx = FxFactory.create cardClass.media.fx.type, @source, @targets, cardClass.media.fx.data
      else
        fx = FxFactory.create 'cast', @source, @targets, cardClass.media.fx?.data
      return fx
