define ['gfx/styles', 'util', 'engine', 'pixi', 'tween'], (STYLES, Util, engine) ->
  HEIGHT = engine.HEIGHT - 100
  WIDTH = engine.WIDTH - engine.WIDTH / 4
  PADDING = 20

  ###
  # Presents the cards in the player's hand while in battle.
  ###
  class CardFan extends PIXI.DisplayObjectContainer
    constructor: (@origin, sprites) ->
      super
      @cardSprites = (s for s in sprites)
      @update()

    update: ->
      # TODO: Add some animation to move cards to the new positions
      # TODO: Organize the cards as a fan instead of a line
      index = 0
      if @cardSprites.length > 0
        startx = @origin.x - ((@cardSprites.length/2)*@cardSprites[0].width/2)
      else
        startx = @origin.x
      for card in @cardSprites
        posx = startx + index * card.width + PADDING
        posy = @origin.y - card.height
        card.position = {x:posx, y:posy}

    addCard: (cardSprite) ->
      @cardSprites.push card
      @update()
    removeCard: (card) ->
      @cardSprites = @cardSprites.filter (c) -> c isnt card
      @update()
