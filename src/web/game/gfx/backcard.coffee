define ['gfx/styles', 'util', 'pixi', 'tween'], (styles, Util) ->

  BACK_TEXTURE = PIXI.Texture.fromImage '/media/images/cards/back.png'

  ###
  # Reverse-side of card, used for drawing opponent's cards that we don't know about yet
  ###
  class BackCard extends PIXI.DisplayObjectContainer
    constructor: (card) ->
      super()
      @backSprite = new PIXI.Sprite BACK_TEXTURE
      @.addChild @backSprite
