define ['battle/animation', 'gui', 'engine', 'util', 'pixi'], (Animation, GUI, engine, Util) ->
  class AttackFx
    constructor: (@data) ->

    animate: (battleAnimator)->
      sourceSprite = battleAnimator.getSprite(@data.source)
      sourcePosition = Util.clone(sourceSprite.position)
      animation = new Animation()
      moveSourceTo = (tgtSprite) -> ->
        Util.spriteTween(sourceSprite, sourceSprite.position, Util.clone(tgtSprite.position), 400)
      for target in @data.targets
        targetSprite = battleAnimator.getSprite(target)
        animation.addTweenStep moveSourceTo(targetSprite), 'attacked-target'
      animation.addTweenStep ->
        Util.spriteTween(sourceSprite, sourceSprite.position, sourcePosition, 400)
      return animation


