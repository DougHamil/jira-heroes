define ['battle/animation', 'gui', 'engine', 'util', 'pixi'], (Animation, GUI, engine, Util) ->
  class BasicTargetFx
    constructor: (@source, targets) ->
      @target = targets[0] if targets.length > 0

    buildAnimation: (battleAnimator)->
      sourceSprite = battleAnimator.getSprite(@source)
      targetSprite = battleAnimator.getSprite(@target)
      sourcePosition = Util.clone(sourceSprite.position)
      targetPosition = Util.clone(targetSprite.position)
      animation = new Animation()
      animation.addTweenStep Util.spriteTween(sourceSprite, sourceSprite.position, Util.clone(targetSprite.position), 400), 'attack'
      #animation.addTweenStep Util.spriteTween(sourceSprite, targetPosition, sourcePosition, 400), 'return'
      return animation


