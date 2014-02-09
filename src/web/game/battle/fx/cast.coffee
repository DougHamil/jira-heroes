define ['battle/fx/base', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (BaseFx, Animation, GUI, engine, Util) ->
  MOVE_TO_TARGET_TIME = 400
  RETURN_POS_TIME = 300
  NO_TARGET_SCALE_FACTOR = 1.5
  NO_TARGET_ANIM_TIME = 500

  ###
  # Very basic Cast animation where a little ring appears on the hero and then a ring appears on all affected targets
  ###
  class CastFx extends BaseFx
    constructor: (@source, @targets, @data) ->
      super

    # Animate the source card moving to the target and then moving back
    _animateSingleTarget: (animator, sSprite, tSprite, animation)->
      animation.on 'start', =>
        parent = sSprite.parent
        parent.removeChild sSprite
        parent.addChild sSprite
        animation.castFxData = {sourcePosition:Util.clone(sSprite.position)}
        console.log "CAST POSITION"
        console.log sSprite.position
      moveSourceTo = ->
        Util.spriteTween(sSprite, sSprite.position, Util.clone(tSprite.position), MOVE_TO_TARGET_TIME)
      animation.addTweenStep moveSourceTo, 'hit-target', @targets
      animation.addUnchainedAnimationStep @_tremble(tSprite)
      animation.addTweenStep ->
        Util.spriteTween(sSprite, sSprite.position, animation.castFxData.sourcePosition, RETURN_POS_TIME)

    _animateMultiTarget: (animator, sSprite, animation)->
      animation.on 'start', =>
        parent = sSprite.parent
        parent.removeChild sSprite
        parent.addChild sSprite
        animation.castFxData = {sourcePosition:Util.clone(sSprite.position)}
      moveSourceTo = (target)-> ->
        Util.spriteTween(sSprite, sSprite.position, Util.clone(target.position), MOVE_TO_TARGET_TIME)
      for target in @targets
        animation.addTweenStep moveSourceTo(target), 'hit-target', target
        animation.addUnchainedAnimationStep @_tremble(target)
      animation.addTweenStep ->
        Util.spriteTween(sSprite, sSprite.position, animation.castFxData.sourcePosition, RETURN_POS_TIME)

    _animateNoTarget: (animator, sSprite, animation)->
      animation.on 'start', =>
        parent = sSprite.parent
        parent.removeChild sSprite
        parent.addChild sSprite
      sourceScale = Util.clone(sSprite.scale)
      animation.addTweenStep ->
        Util.scaleSpriteTween sSprite, NO_TARGET_SCALE_FACTOR, NO_TARGET_ANIM_TIME
      animation.addTweenStep ->
        Util.scaleSpriteTween sSprite, sourceScale, NO_TARGET_ANIM_TIME

    _tremble: (sprite) ->
      animation = new Animation()
      jitterSteps = 5
      initialPosition = Util.clone(sprite.position)
      for i in [0...5]
        animation.addTweenStep ->
          return Util.spriteTween sprite, sprite.position, Util.pointJitter(sprite.position, 10), 50
      animation.addTweenStep =>
        return Util.spriteTween sprite, sprite.position, initialPosition, 50
      return animation

