define ['gfx/styles', 'util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  HIGHLIGHT_WIDTH = 10
  CARD_WIDTH = 300
  CARD_HEIGHT = 100
  class DeckButton extends PIXI.DisplayObjectContainer
    constructor: (deck, hero) ->
      super
      if hero.media.icon?
        texture = PIXI.Texture.fromImage hero.media.icon
        @icon = new PIXI.Sprite texture
        @icon.position = {x:0, y:0}
        @icon.scale = {x:0.25, y:0.25}
      @name = new PIXI.Text deck.name, STYLES.TEXT
      @cardText = new PIXI.Text deck.cards.length + " Cards", STYLES.TEXT
      @bg = new PIXI.Graphics()
      @bg.width = CARD_WIDTH
      @bg.height = CARD_HEIGHT
      @bg.beginFill STYLES.BUTTON_COLOR
      @bg.drawRect 0, 0, @bg.width, @bg.height
      @bg.endFill()
      @highlight = new PIXI.Graphics()
      @highlight.beginFill STYLES.HIGHLIGHT_COLOR
      @highlight.drawRect(-HIGHLIGHT_WIDTH, -HIGHLIGHT_WIDTH, @bg.width + HIGHLIGHT_WIDTH*2 , @bg.height + HIGHLIGHT_WIDTH*2)
      @highlight.endFill()
      @highlight.visible = false
      @name.position = {x:0, y:@bg.height - @name.height}
      @cardText.position = {x:@bg.width - @cardText.width, y:0}
      @cont = new PIXI.DisplayObjectContainer()
      @cont.addChild @highlight
      @cont.addChild @bg
      @cont.addChild @cardText
      if @icon?
        @cont.addChild @icon
      @cont.addChild @name
      @.addChild @cont
      @.hitArea = new PIXI.Rectangle 0, 0, @bg.width, @bg.height
      @.interactive = true
      @width = @bg.width
      @height = @bg.height

    setHighlight: (enabled) ->
      @highlight.visible = enabled

    onClick: (callback) ->
      @.click = =>
        callback(@)
