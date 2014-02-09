define ['battle/animation', 'gui', 'engine', 'util', 'pixi'], (Animation, GUI, engine, Util) ->
  class BaseFx
    constructor: (@source, @targets, @data) ->
      if @targets? and @targets instanceof Array and @targets.length is 1
        @targets = @targets[0]
      if @targets? and @targets not instanceof Array
        @target = @targets

    _animateSingleTarget: (animator, source, target, animation)->

    _animateMultiTarget: (animator, source, targets, animation)->

    _animateNoTarget: (animator, source, animation)->

    animate: (battleAnimator)->
      animation = new Animation()
      sourceSprite = battleAnimator.getSprite(@source)
      if not @targets?
        @_animateNoTarget(battleAnimator, @source, animation)
      else if @targets instanceof Array
        @_animateMultiTarget(battleAnimator, @source, @targets, animation)
      else
        @_animateSingleTarget(battleAnimator, @source, @targets, animation)
      return animation


