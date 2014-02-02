define ['gfx/styles', 'util', 'pixi', 'tween'], (STYLES, Util) ->
  CARD_SIZE =
    width: 150
    height: 214
  IMAGE_PATH = "/media/images/cards/"
  FACE_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'card_back.png'

  ###
  # Draws a flipped card, basically just the backside of the card
  ###
  class FlippedCard extends PIXI.DisplayObjectContainer
    constructor: ->
      super
      @width = CARD_SIZE.width
      @height = CARD_SIZE.height
      @faceSprite = new PIXI.Sprite FACE_TEXTURE
      @faceSprite.width = @width
      @faceSprite.height = @height
      @.addChild @faceSprite
