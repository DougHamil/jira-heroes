define ['battle/animation', 'gfx/styles', 'util', 'pixi', 'tween'], (Animation, styles, Util) ->
  class Scanline extends PIXI.DisplayObjectContainer
    constructor: (horiz, tint) ->
      super
      horiz = false if not horiz?
      tint = 0x336677 if not tint?
      length = (0.5 + Math.random()) * 500
      time = (Math.random()) * 5000 + 5000
      x = Math.random() * 1024
      if horiz
        x = Math.random() * 768
      @gfx = new PIXI.Graphics()
      @gfx.lineStyle 1, tint
      if not horiz
        @gfx.moveTo x, -length
        @gfx.lineTo x, 0
      else
        @gfx.moveTo -length, x
        @gfx.lineTo 0, x
      gfx= @gfx
      start = Math.random() * 1000
      if horiz
        gfx.position = {x:start, y:x}
      else
        gfx.position = {x:x, y:start}
      tween = new TWEEN.Tween({pos:start}).to({pos:2000}, time * (start/length)).onUpdate ->
        if horiz
          gfx.position = {x:@pos, y:x}
        else
          gfx.position = {x:x, y:@pos}
      tween.onComplete ->
        tween2 = new TWEEN.Tween({pos:0}).to({pos:2000}, time).repeat(Infinity).onUpdate ->
          if horiz
            gfx.position = {x:@pos, y:x}
          else
            gfx.position = {x:x, y:@pos}
        tween2.start()
      tween.start()
      @.addChild @gfx
      @gfx.alpha = 0.5
