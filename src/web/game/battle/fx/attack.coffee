define ['battle/fx/base', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (BaseFx, Animation, GUI, engine, Util) ->
  MOVE_TO_TARGET_TIME = 400
  RETURN_POS_TIME = 300
  NO_TARGET_SCALE_FACTOR = 1.5
  NO_TARGET_ANIM_TIME = 500

  class AttackFx extends BaseFx
    constructor: (@source, @targets, @data) ->
      super

    # Animate the source card moving to the target and then moving back
    _animateSingleTarget: (animator, source, target, animation)->
      _data = {}
      animation.on 'start', =>
        sSprite = animator.getSprite(source)
        parent = sSprite.parent
        parent.removeChild sSprite
        parent.addChild sSprite
        _data.sSprite = sSprite
        _data.tSprite = animator.getSprite(target)
        _data.sPosition = Util.clone(sSprite.position)
      moveSourceTo = ->
        Util.spriteTween(_data.sSprite, _data.sSprite.position, Util.clone(_data.tSprite.position), MOVE_TO_TARGET_TIME)
      animation.addTweenStep moveSourceTo, 'hit-target', target
      animation.addUnchainedAnimationStep =>
        return @_tremble(_data.tSprite)
      animation.addTweenStep ->
        Util.spriteTween(_data.sSprite, _data.sSprite.position, _data.sPosition, RETURN_POS_TIME)

    _animateMultiTarget: (animator, source, targets, animation)->
      _data = {}
      animation.on 'start', =>
        sSprite = animator.getSprite(source)
        parent = sSprite.parent
        parent.removeChild sSprite
        parent.addChild sSprite
        _data.sSprite = sSprite
        _data.sPosition = Util.clone(sSprite.position)
      moveSourceTo = (target)-> ->
        tSprite = animator.getSprite(target)
        Util.spriteTween(_data.sSprite, _data.sSprite.position, Util.clone(tSprite.position), MOVE_TO_TARGET_TIME)
      for target in targets
        animation.addTweenStep moveSourceTo(target), 'hit-target', target
        animation.addUnchainedAnimationStep => return @_tremble(animator.getSprite(target))
      animation.addTweenStep ->
        Util.spriteTween(_data.sSprite, _data.sSprite.position, _data.sPosition, RETURN_POS_TIME)

    _animateNoTarget: (animator, source, animation)->
      _data = {}
      animation.on 'start', =>
        sSprite = animator.getSprite(source)
        parent = sSprite.parent
        parent.removeChild sSprite
        parent.addChild sSprite
        _data.sSprite = sSprite
        _data.sScale = Util.clone(sSprite.scale)
      animation.addTweenStep ->
        Util.scaleSpriteTween _data.sSprite, NO_TARGET_SCALE_FACTOR, NO_TARGET_ANIM_TIME
      animation.addTweenStep ->
        Util.scaleSpriteTween _data.sSprite, _data.sScale, NO_TARGET_ANIM_TIME

    _tremble: (sprite) ->
      animation = new Animation()
      animation.on 'start', =>
        animation.trembleFxData = {sourcePosition: Util.clone(sprite.position)}
      jitterSteps = 5
      for i in [0...5]
        animation.addTweenStep ->
          return Util.spriteTween sprite, sprite.position, Util.pointJitter(sprite.position, 10), 50
      animation.addTweenStep =>
        return Util.spriteTween sprite, sprite.position, animation.trembleFxData.sourcePosition, 50
      return animation

