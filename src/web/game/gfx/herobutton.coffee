define ['gfx/styles', 'util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  HIGHLIGHT_WIDTH = 10
  CARD_HEIGHT = 300
  CARD_WIDTH = 200
  class HeroButton extends PIXI.DisplayObjectContainer
    constructor: (hero) ->
      super
      if hero.media.icon?
        texture = PIXI.Texture.fromImage hero.media.icon
        @icon = new PIXI.Sprite texture
        @icon.anchor = {x:0.5, y:0.5}
        @icon.position = {x:100, y:150}
      @name = new PIXI.Text hero.displayName, STYLES.TEXT
      @bg = new PIXI.Graphics()
      @bg.width = CARD_WIDTH
      @bg.height = CARD_HEIGHT
      @bg.beginFill STYLES.BUTTON_COLOR
      @bg.drawRect(0, 0, @bg.width, @bg.height)
      @highlight = new PIXI.Graphics()
      @highlight.beginFill STYLES.HIGHLIGHT_COLOR
      @highlight.drawRect(-HIGHLIGHT_WIDTH, -HIGHLIGHT_WIDTH, @bg.width + HIGHLIGHT_WIDTH*2 , @bg.height + HIGHLIGHT_WIDTH*2)
      @highlight.visible = false
      @name.anchor = {x:0.5, y:1.0}
      @name.position = {x:100, y:300 - (@name.height + 20)}

      @from = {x:0, y:0}
      @to = {x:0, y:10}
      @cont = new PIXI.DisplayObjectContainer()
      @cont.interactive = true
      @cont.hitArea = new PIXI.Rectangle 0, 0, @bg.width, @bg.height
      @cont.addChild @highlight
      @cont.addChild @bg
      if @icon
        @cont.addChild @icon
      @cont.addChild @name
      @tweens =
        selected: => Util.spriteTween(@cont, @from, @to, 500).repeat(Infinity).yoyo(true).easing(TWEEN.Easing.Sinusoidal.InOut)

      @.addChild @cont
      @.interactive = true
      @.mouseover = =>
        @animate 'selected'
      @.mouseout = =>
        @animate 'none'
      @width = @bg.width
      @height = @bg.height

    setHighlight: (enabled) ->
      @highlight.visible = enabled

    onClick: (callback) ->
      @.click = =>
        callback(@)

    animate: (animation) ->
      if @lastAnim? and @lastAnim is animation
        return
      @lastAnim = animation
      if animation == 'none'
        if @activeTween?
          @activeTween.repeat(0)
        @activeTween = null
        return
      @activeTween = @tweens[animation]()
      @activeTween.repeat(Infinity).start()

