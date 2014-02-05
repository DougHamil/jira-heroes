define ['battle/animation', 'gui', 'engine', 'util', 'pixi'], (Animation, GUI, engine, Util) ->
  class BaseFx
    constructor: (@source, @targets, @data) ->
      if @targets? and @targets instanceof Array and @targets.length is 1
        @targets = @targets[0]
      if @targets? and @targets not instanceof Array
        @target = @targets

    _animateSingleTarget: (animator, sourceSprite, animation)->

    _animateMultiTarget: (animator, sourceSprite, animation)->

    _animateNoTarget: (animator, sourceSprite, animation)->

    animate: (battleAnimator)->
      animation = new Animation()
      sourceSprite = battleAnimator.getSprite(@source)
      console.log sourceSprite
      console.log @source
      if not @targets?
        @_animateNoTarget(battleAnimator, sourceSprite, animation)
      else if @targets instanceof Array
        @_animateMultiTragets(battleAnimator, sourceSprite, animation)
      else
        @_animateSingleTarget(battleAnimator, sourceSprite, battleAnimator.getSprite(@targets), animation)
      return animation


