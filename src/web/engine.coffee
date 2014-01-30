define ['jquery', 'pixi', 'tween'], ($, PIXI) ->
  window.PIXI = PIXI
  stage = new PIXI.Stage 0xEDC951, true
  renderer = new PIXI.autoDetectRenderer 1024, 768, $('#mainCanvas').get(0)
  engine =
    stage:stage
    renderer:renderer
    updateCallbacks:[]
    WIDTH: renderer.width
    HEIGHT: renderer.height
    timeMultiplier:1
    paused:false

  animate = ->
    requestAnimFrame animate
    for callback in engine.updateCallbacks
      callback()
    engine.renderer.render engine.stage
    TWEEN.update()

  requestAnimFrame animate

  return engine
