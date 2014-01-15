define ['gfx/styles', 'util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  class DeckCardListEntry extends PIXI.DisplayObjectContainer
    constructor: (width, height, card) ->
      super
      @countTxt = new PIXI.Text '1', STYLES.TEXT
      @energyTxt = new PIXI.Text card.energy, STYLES.TEXT
      @nameTxt = new PIXI.Text card.displayName, STYLES.TEXT
      @bg = new PIXI.Graphics()
      @bg.width = width
      @bg.height = height
      @bg.beginFill STYLES.BUTTON_COLOR
      @bg.drawRect 0, 0, @bg.width, @bg.height

      @nameTxt.position = {x:@countTxt.width + 10, y: 0}

      @.addChild @bg
      @.addChild @countTxt
      @.addChild @energyTxt
      @.addChild @nameTxt

      @setCount(1)

    setCount: (count) ->
      @countTxt.setText(count.toString())
      @countTxt.position = {x: @bg.width - @countTxt.width, y:0}
