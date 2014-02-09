define ['jquery', 'pixi', 'tween'], ($) ->
  copy = (obj) ->
    return $.extend {}, {}, obj

  UTILS =
    clone:copy
    copy:copy
    vectorLength: (a) ->
      return Math.sqrt((a.x*a.x) + (a.y*a.y))
    vectorNormalize: (a) ->
      len = UTILS.vectorLength(a)
      return {x:a.x/len, y:a.y/len}
    pointsEqual: (a, b) -> return a.x is b.x and a.y is b.y
    pointSubtract: (a, b) -> return {x: a.x - b.x, y: a.y - b.y}
    pointAdd: (a, b) -> return {x: a.x + b.x, y: a.y + b.y}
    pointJitter: (pt, amount) ->
      out = copy(pt)
      out.x += (amount * (Math.random() - 0.5))
      out.y += (amount * (Math.random() - 0.5))
      return out
    fadeSpriteTween: (sprite, alpha, time) ->
      tween = new TWEEN.Tween({alpha:sprite.alpha}).to({alpha:alpha}, time).onUpdate ->
        sprite.alpha = @alpha
      return tween
    scaleSpriteTween: (sprite, factor, time) ->
      destScale = UTILS.copy(sprite.scale)
      if factor.x? and factor.y?
        destScale = factor
      else
        destScale.x *= factor
        destScale.y *= factor
      tween = new TWEEN.Tween(UTILS.copy(sprite.scale)).to(destScale, time).onUpdate ->
        for key, value of @
          if key is 'x'
            sprite.scale.x = value
          else if key is 'y'
            sprite.scale.y = value
      return tween
    spriteTween:(sprite, from, to, time, options, onComplete) ->
      tween = new TWEEN.Tween(UTILS.copy(from))
        .to(UTILS.copy(to), time)
        .onUpdate( ->
          for key, value of @
            if sprite[key]?
              sprite[key] = value
            else if key == 'x'
              sprite.position.x = value
            else if key == 'y'
              sprite.position.y = value
        )
      if options?.yoyo?
        tween.yoyo options.yoyo
      if options?.easing?
        tween.easing options.easing
      if options?.repeat?
        tween.repeat options.repeat
      if onComplete?
        tween.onComplete(onComplete)
      return tween
    drawArrow: (src, tgt) ->
      graphics = new PIXI.Graphics()
      graphics.lineStyle 5, 0xFF0000
      graphics.moveTo src.x, src.y
      graphics.lineTo tgt.x, tgt.y
      return graphics
  ###
  # Chain an array of tweens together
  ###
  chainTweens: (tweens) ->
    if not tweens? or tweens.length is 0
      return null
    tween = tweens[0]
    for i in [1...tweens.length]
      tween.chain(tweens[i])
      tween = tweens[i]
    return tweens[0]

  return UTILS

