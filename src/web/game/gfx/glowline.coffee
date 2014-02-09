define ['battle/animation', 'gfx/styles', 'util', 'engine','pixi', 'tween'], (Animation, styles, Util, engine) ->
  TEXTURE = PIXI.Texture.fromImage '/media/images/fx/soft_small.png'
  GLOW_SCALE = 0.2
  TIME = 1000
  shadeColor2 = (color, percent) ->
    f=parseInt(color.slice(1),16)
    t = if percent < 0 then 0 else 255
    p = if percent < 0 then percent * -1 else percent
    R=f>>16
    G=f>>8&0x00FF
    B=f&0x0000FF
    return "#"+(0x1000000+(Math.round((t-R)*p)+R)*0x10000+(Math.round((t-G)*p)+G)*0x100+(Math.round((t-B)*p)+B)).toString(16).slice(1)

  class GlowLine extends PIXI.DisplayObjectContainer
    constructor: (start, end, tint) ->
      super
      tint = 0x336677 if not tint?
      @gfx = new PIXI.Graphics()
      @gfx.lineStyle 1, tint
      @gfx.moveTo start.x, start.y
      @gfx.lineTo end.x, end.y

      glowTint = shadeColor2(Util.hexColorToString(tint), 0.1)

      @emitter = new Proton.Emitter()
      @emitter.rate = new Proton.Rate(2, 0.0001)
      @emitter.addInitialize new Proton.Mass(1)
      @emitter.addInitialize new Proton.ImageTarget(TEXTURE)
      @emitter.addInitialize new Proton.Life(2, 8)

      @emitter.addBehaviour new Proton.Color(glowTint)
      @emitter.addBehaviour new Proton.Scale(GLOW_SCALE, 0)
      @emitter.addBehaviour new Proton.Alpha(1.0, 0.0)

      engine.proton.addEmitter @emitter

      _that = @
      emitter = @emitter
      tween = new TWEEN.Tween(Util.clone(start)).to(Util.clone(end), TIME).repeat(Infinity).yoyo(true).onUpdate ->
        pos = {x:_that.position.x + @x,y:_that.position.y + @y}
        emitter.p.x = pos.x
        emitter.p.y = pos.y
      @.addChild @gfx
      emitter.emit()
      tween.start()

