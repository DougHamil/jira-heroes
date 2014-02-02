define ['gfx/styles', 'gfx/card', 'gfx/pagedcardgrid', 'util', 'engine', 'pixi', 'tween'], (STYLES, Card, PagedCardGrid, Util, engine) ->
  HEIGHT = engine.HEIGHT - 100
  WIDTH = engine.WIDTH - engine.WIDTH / 4

  ###
  # Presents an interface to allow the user to pick a card from the list of avaiable cards
  ###
  class CardPicker extends PIXI.DisplayObjectContainer
    constructor: (@cards, @cardClasses) ->
      super
      @cardSprites = {}
      for card in @cards
        onClick = (cardId) => =>
          if @onCardPickedCallback?
            @onCardPickedCallback(cardId)
        sprite = Card.FromClass @cardClasses[card]
        sprite.onClick onClick(card)
        @cardSprites[card] = sprite
      @cardGrid = new PagedCardGrid WIDTH, HEIGHT, 10, 4, 2, (card for cardId, card of @cardSprites)
      WIDTH = @cardGrid.width
      HEIGHT = @cardGrid.height
      @bg = new PIXI.Graphics()
      @bg.width = WIDTH
      @bg.height = HEIGHT
      @bg.beginFill STYLES.DARK_BACKGROUND_COLOR
      @bg.drawRect 0, 0, @bg.width, @bg.height
      @width = @bg.width
      @height = @bg.height
      @.addChild @bg
      @.addChild @cardGrid

    getSprite: (cardId) -> return @cardSprites[cardId]

    onCardPicked: (@onCardPickedCallback) ->
