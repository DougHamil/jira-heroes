define ['jquery', 'gui', 'engine', 'util', 'pixi'], ($, GUI, engine, Util) ->
  HAND_ORIGIN = {x:20, y:engine.HEIGHT - 20}
  HAND_ANIM_TIME = 1000
  HAND_HOVER_OFFSET = 50
  HAND_PADDING = 20
  HOVER_ANIM_TIME = 200

  ###
  # Manages all card sprites in the battle by positioning and animating them
  # as the battle unfolds.
  ###
  class CardManager extends PIXI.DisplayObjectContainer
    constructor: (@cardClasses, @userId, @battle) ->
      super
      # Build all known card sprites
      @cardSprites = {}
      @handSprites = []
      for card in @battle.getCardsInHand()
        @putCardInHand card, false
      engine.updateCallbacks.push => @update()

    putCardInHand: (card, animate) ->
      # Default to animate
      animate = true if not animate?
      sprite = @getCardSprite card
      position = @getOpenHandPosition()
      addInteraction = (sprite) =>
        =>
          to = {x:sprite.position.x, y:sprite.position.y-HAND_HOVER_OFFSET}
          from = {x:sprite.position.x, y:sprite.position.y}
          sprite.onHoverStart =>
            tween = Util.spriteTween sprite, sprite.position, to, HOVER_ANIM_TIME
            tween.start()
            sprite.tween = tween
          sprite.onHoverEnd =>
            if @dragSprite isnt sprite
              tween = Util.spriteTween sprite, sprite.position, from, HOVER_ANIM_TIME
              tween.start()
              sprite.tween = tween
          sprite.onMouseDown =>
            if sprite.tween?
              sprite.tween.stop()
              @dragOffset = @stage.getMousePosition().clone()
              @dragOffset.x -= sprite.position.x
              @dragOffset.y -= sprite.position.y
              @dragSprite = sprite
          sprite.onMouseUp =>
            if sprite.tween?
              sprite.tween.stop()
            if @dragSprite is sprite
              @dragSprite = null
              tween = Util.spriteTween sprite, sprite.position, from, HOVER_ANIM_TIME
              tween.start()
              sprite.tween = tween
      if animate
        tween = Util.spriteTween(sprite, sprite.position, position, HAND_ANIM_TIME).start()
        sprite.tween = tween
        tween.onComplete addInteraction(sprite)
      else
        sprite.position = position
        addInteraction(sprite)()
      @handSprites.push sprite

    update: ->
      if @dragSprite? and @stage?
        pos = @stage.getMousePosition().clone()
        pos.x -= @dragOffset.x
        pos.y -= @dragOffset.y
        @dragSprite.position = pos

    getOpenHandPosition: ->
      return {x:HAND_ORIGIN.x + (@getCardWidth() + HAND_PADDING) * @handSprites.length, y:HAND_ORIGIN.y - @getCardHeight()}

    getCardHeight: ->
      for id, sprite of @cardSprites
        return sprite.height
      return 0
    getCardWidth: ->
      for id, sprite of @cardSprites
        return sprite.width
      return 0
    getCardSprite: (card) ->
      sprite = @cardSprites[card._id]
      if not sprite?
        sprite = @buildSpriteForCard(card)
        sprite.card = card
        @cardSprites[card._id] = sprite
        @.addChild sprite
      return sprite

    buildSpriteForCard: (card) ->
      new GUI.Card @cardClasses[card.class], card.damage, card.health, card.status
