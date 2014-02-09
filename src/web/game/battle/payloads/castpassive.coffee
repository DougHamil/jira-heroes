define ['battle/fx/factory','battle/animation', 'util'], (FxFactory, Animation, Util) ->
  class CastPassivePayload
    constructor: (action) ->
      @type = 'cast-passive'
      @source = action.source
      @targets = action.targets
      @name = action.name
      @fx = action.fx
      @actions = []

    # Just accumulate actions for now
    onAction: (action) -> @actions.push action

    animate: (animator, battle) ->
      animation = new Animation()

      console.log "PASSIVE FX"
      console.log @fx
      if @fx?
        fx = @_buildFx(@fx)
        if fx?
          animation.addAnimationStep fx.animate(animator)

      # Animated any actions that occur after the spell is cast
      for action in @actions
        if action.target?
          animation.addAnimationStep animator.getBattleObject(action.target).animateAction(action)

      animation.on 'complete', => animator.animateActions(@actions)

      return animation

    _buildFx: (fxModel) ->
      if not fxModel? or not fxModel.type
        return null
      return FxFactory.create fxModel.type, @source, @targets, fxModel.data
