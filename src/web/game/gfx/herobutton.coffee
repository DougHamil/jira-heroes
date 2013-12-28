define ['gfx/styles', 'util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  class HeroButton extends PIXI.DisplayObjectContainer
    constructor: (hero) ->
      super
      #TODO: Add animated sprite for hero
      if hero.media.character.icon?
        texture = PIXI.Texture.fromImage hero.media.character.icon
        @icon = new PIXI.Sprite texture
        @icon.anchor = {x:0.5, y:0.5}
        @icon.position = {x:100, y:150}
      @name = new PIXI.Text hero.name, STYLES.TEXT
      @class = new PIXI.Text hero.class, STYLES.TEXT
      @bg = new PIXI.Graphics()
      @bg.beginFill STYLES.BUTTON_COLOR
      @bg.drawRect(0, 0, 200, 300)
      @name.anchor = {x:0.5, y:1.0}
      @class.anchor = {x:0.5, y:1.0}
      @class.position = {x:100, y:300}
      @name.position = {x:100, y:300 - (@class.height + 20)}
      @from = {x:0, y:0}
      @to = {x:0, y:10}
      @cont = new PIXI.DisplayObjectContainer()
      @tweens =
        selected: Util.spriteTween(@cont, @from, @to, 500).repeat(Infinity).yoyo(true).easing(TWEEN.Easing.Sinusoidal.InOut)
      @cont.addChild @bg
      if @icon
        @cont.addChild @icon
      @cont.addChild @name
      @cont.addChild @class
      @.addChild @cont
      @cont.interactive = true
      @cont.hitArea = new PIXI.Rectangle 0, 0, 200, 300
      @.interactive = true

      @.mouseover = =>
        @animate 'selected'
      @.mouseout = =>
        @animate 'none'

    onClick: (callback) ->
      @.click = =>
        callback(@)

    animate: (animation) ->
      if @activeTween?
        @activeTween.repeat(0)
      if animation == 'none'
        return
      @activeTween = @tweens[animation]
      @tweens[animation].repeat(Infinity).start()

