define ['jquery', 'pixi', 'tween'], ($) ->
  stage = new PIXI.Stage 0xEDC951, true
  renderer = new PIXI.autoDetectRenderer 1000, 800, $('#mainCanvas').get(0)

  TWEEN._timeMultiplier = 1
  engine =
    stage:stage
    renderer:renderer
    updateCallbacks:[]
    WIDTH: renderer.width
    HEIGHT: renderer.height

  animate = ->
    requestAnimFrame animate
    for callback in engine.updateCallbacks
      callback()
    engine.renderer.render engine.stage
    TWEEN.update()

  requestAnimFrame animate

  return engine
