define ['battle/fx/factory', 'battle/animation', 'util'], (FxFactory, Animation, Util) ->
  class CastHeroAbilityPayload
    constructor: (action) ->
      @type = 'cast-hero-ability'
      @player = action.player
      @source = action.hero
      @targets = action.targets
      @actions = []

    onAction: (action) -> @actions.push action

    animate: (animator, battle) ->
      animation = new Animation()

      heroClass = animator.getHeroClass(@source)

      fx = @_buildFx(heroClass)
      animation.addAnimationStep fx.animate(animator)
      animation.addAnimationStep animator.getBattleHero(@source).animateAbilityCasted()

      # Animated any actions that occur after the spell is cast
      for action in @actions
        if action.target?
          animation.addUnchainedAnimationStep animator.getBattleObject(action.target).animateAction(action)
        else if action.hero?
          animation.addUnchainedAnimationStep animator.getBattleObject(action.hero).animateAction(action)
      animation.on 'complete', => animator.animateActions(@actions)
      return animation

    _buildFx: (heroClass) ->
      fx = null
      if heroClass.ability.media.fx? and heroClass.ability.media.fx.type?
        fx = FxFactory.create heroClass.ability.media.fx.type, @source, @targets, heroClass.ability.media.fx.data
      else
        fx = FxFactory.create 'cast', @source, @targets, heroClass.ability.media.fx?.data
      return fx
