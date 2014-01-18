define ['jquery', 'pixi', 'tween'], ($) ->
  copy = (obj) ->
    return $.extend {}, {}, obj

  UTILS =
    clone:copy
    copy:copy
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

  return UTILS

