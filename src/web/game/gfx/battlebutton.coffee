define ['gfx/styles', 'util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  HIGHLIGHT_WIDTH = 10
  CARD_WIDTH = 300
  CARD_HEIGHT = 50
  class BattleButton extends PIXI.DisplayObjectContainer
    constructor: (battle, users) ->
      super
      console.log users
      console.log battle
      if battle.users.length > 0
        @name = new PIXI.Text users[battle.users[0]].name, STYLES.TEXT
      else
        @name = new PIXI.Text 'Unknown', STYLES.TEXT
      @bg = new PIXI.Graphics()
      @bg.width = CARD_WIDTH
      @bg.height = CARD_HEIGHT
      @bg.beginFill STYLES.BUTTON_COLOR
      @bg.drawRect 0, 0, @bg.width, @bg.height
      @highlight = new PIXI.Graphics()
      @highlight.beginFill STYLES.HIGHLIGHT_COLOR
      @highlight.drawRect(-HIGHLIGHT_WIDTH, -HIGHLIGHT_WIDTH, @bg.width + HIGHLIGHT_WIDTH*2 , @bg.height + HIGHLIGHT_WIDTH*2)
      @highlight.visible = false
      @name.position = {x:0, y:@bg.height - @name.height}
      @cont = new PIXI.DisplayObjectContainer()
      @cont.addChild @highlight
      @cont.addChild @bg
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
