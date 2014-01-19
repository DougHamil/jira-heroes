define ['jquery', 'gui', 'engine', 'util', 'pixi'], ($, GUI, engine, Util) ->
  DECK_ORIGIN = {x:engine.WIDTH + 200, y: engine.HEIGHT}
  FIELD_ORIGIN = {x:20, y: engine.HEIGHT/2}
  ENEMY_FIELD_ORIGIN = {x:20, y: 100}
  FIELD_PADDING = 50
  HAND_ORIGIN = {x:20, y:engine.HEIGHT - 20}
  HAND_ANIM_TIME = 1000
  HAND_HOVER_OFFSET = 50
  HAND_PADDING = 20
  HOVER_ANIM_TIME = 200
  DEFAULT_TWEEN_TIME = 400
  TOKEN_CARD_OFFSET = 100
  FIELD_AREA = new PIXI.Rectangle 20, 200, engine.WIDTH - 80, 500

  ###
  # Manages all card sprites in the battle by positioning and animating them
  # as the battle unfolds.
  ###
  class CardManager extends PIXI.DisplayObjectContainer
    constructor: (@cardClasses, @userId, @battle) ->
      super
      @cardSprites = {}
      @tokenSprites = {}
      @cardTokens = {}
      @handSprites = []
      @fieldSprites = []
      @enemyFieldSprites = []
      @cardSpriteLayer = new PIXI.DisplayObjectContainer()
      @tokenSpriteLayer = new PIXI.DisplayObjectContainer()
      @.addChild @tokenSpriteLayer
      @.addChild @cardSpriteLayer
      for card in @battle.getCardsInHand()
        @putCardInHand card, false
      for card in @battle.getCardsOnField()
        @putCardOnField card, false
      for card in @battle.getEnemyCardsOnField()
        console.log card
        @putEnemyCardOnField card, false
      engine.updateCallbacks.push => @update()
      document.body.onmouseup = =>
        if @targetingSource?
          # If a target wasn't found, then return the card to it's source position
          if not @onTargeted(@targetingSource, @stage.getMousePosition().clone())
            if @targetingSource.dropTween?
              @targetingSource.dropTween.start()
          @targetingSource = null
      @battle.on 'action-draw-card', (action) => @onDrawCardAction(action)
      @battle.on 'action-end-turn', (action) => @onEndTurnAction(action)
      @battle.on 'action-play-card', (action) => @onPlayCardAction(action)
      @battle.on 'action-damage', (action) => @onDamageAction(action)

    onDamageAction: (action) ->
      cardSprite = @cardSprites[action.target]
      tokenSprite = @tokenSprites[action.target]
      if cardSprite?
        cardSprite.setHealth(@battle.getCard(action.target).health)
      if tokenSprite
        tokenSprite.setHealth(@battle.getCard(action.target).health)
    onPlayCardAction: (action) ->
      if action.player isnt @userId
        @putEnemyCardOnField action.card

    onEndTurnAction: (action) ->
      if action.player is @userId
        @fixHandPositions()

    onDrawCardAction: (action) ->
      if action.player is @userId
        @putCardInHand(action.card)

    placeFieldToken: (cardSprite, tokenSprite, position, isTargetSource, animate) ->
      addInteraction = (sprite) => =>
        cardPos = Util.clone(sprite.position)
        cardPos.x += sprite.width + TOKEN_CARD_OFFSET
        sprite.cardSprite.position = cardPos
        sprite.cardSprite.visible = false
        sprite.visible = true
        # Show card when token is hovered
        sprite.onHoverStart =>
          sprite.cardSprite.visible = true
        sprite.onHoverEnd =>
          sprite.cardSprite.visible = false
        if isTargetSource
          sprite.onMouseDown => @setTargetingSource(sprite)
      tokenSprite.visible = false
      tokenSprite.position = position
      if animate
        # Animate card sprite going to token position
        tween = Util.spriteTween(cardSprite, cardSprite.position, position, DEFAULT_TWEEN_TIME)
        cardSprite.tween = tween
        tween.start()
        tween.onComplete addInteraction(tokenSprite)
      else
        addInteraction(tokenSprite)()

    putEnemyCardOnField: (card, animate) ->
      animate = true if not animate?
      cardSprite = @getCardSprite card
      tokenSprite = @getTokenSprite card
      position = @getOpenEnemyFieldPosition()
      @placeFieldToken cardSprite, tokenSprite, position, false, animate
      @enemyFieldSprites.push tokenSprite

    putCardOnField: (card, animate) ->
      # Default to animate
      animate = true if not animate?
      cardSprite = @getCardSprite card
      tokenSprite = @getTokenSprite card
      position = @getOpenFieldPosition()
      @placeFieldToken cardSprite, tokenSprite, position, true, animate
      @fieldSprites.push tokenSprite
      @handSprites = @handSprites.filter (s) -> s isnt cardSprite

    setHandInteraction: (sprite) ->
      cardClass = @cardClasses[sprite.card.class]
      to = {x:sprite.position.x, y:sprite.position.y-HAND_HOVER_OFFSET}
      from = {x:sprite.position.x, y:sprite.position.y}
      sprite.onHoverStart =>
        if not @dragSprite? and not @targetingSource?
          tween = Util.spriteTween sprite, sprite.position, to, HOVER_ANIM_TIME
          tween.start()
          sprite.tween = tween
      sprite.onHoverEnd =>
        if @dragSprite isnt sprite and @targetingSource isnt sprite
          tween = Util.spriteTween sprite, sprite.position, from, HOVER_ANIM_TIME
          tween.start()
          sprite.tween = tween
        else if @targetingSource is sprite
          tween = Util.spriteTween sprite, sprite.position, from, HOVER_ANIM_TIME
          sprite.dropTween = tween
      sprite.onMouseDown =>
        # If this card has a cast ability, then it's a spell card, so pick a target
        if cardClass.playAbility?
          @setTargetingSource(sprite)
        else
          if sprite.tween?
            sprite.tween.stop()
            @dragOffset = @stage.getMousePosition().clone()
            @dragOffset.x -= sprite.position.x
            @dragOffset.y -= sprite.position.y
            @dragSprite = sprite
            @.removeChild @dragSprite
            @.addChild @dragSprite
      sprite.onMouseUp =>
        if sprite.tween?
          sprite.tween.stop()
        if @dragSprite is sprite
          @dragSprite = null
          tween = Util.spriteTween sprite, sprite.position, from, HOVER_ANIM_TIME
          sprite.tween = tween
          @onCardDropped sprite

    putCardInHand: (card, animate) ->
      # Default to animate
      animate = true if not animate?
      sprite = @getCardSprite card
      position = @getOpenHandPosition()
      sprite.sourcePosition = position
      addInteraction = (sprite) => => @setHandInteraction(sprite)
      if animate
        if sprite.position.x is 0 and sprite.position.y is 0
          sprite.position = Util.clone(DECK_ORIGIN)
        tween = Util.spriteTween(sprite, sprite.position, position, HAND_ANIM_TIME).start()
        sprite.tween = tween
        tween.onComplete addInteraction(sprite)
      else
        sprite.position = position
        addInteraction(sprite)()
      @handSprites.push sprite

    fixHandPositions: ->
      index = 0
      setInteractions = (sprite) => => @setHandInteraction(sprite)
      for cardSprite in @handSprites
        pos = @getHandPositionAt(index)
        if cardSprite.x isnt pos.x or cardSprite.y isnt pos.y
          @removeInteractions(cardSprite)
          cardSprite.tween = Util.spriteTween(cardSprite, cardSprite.position, pos, HAND_ANIM_TIME)
          cardSprite.tween.start()
          cardSprite.tween.onComplete setInteractions(cardSprite)
        index++

    onTargeted: (sourceSprite, targetPosition) ->
      for cardId, tokenSprite of @tokenSprites
        if tokenSprite.contains(targetPosition)
          # If this is a spell card being played from the hand, then play the spell with the target
          if sourceSprite in @handSprites
            console.log "Attempting to cast spell of card #{sourceSprite.card._id}"
            @battle.emitPlayCardEvent sourceSprite.card._id, cardId, (err) =>
              if err?
                console.log err
                sourceSprite.tween.start()
          # If this is a token sprite and we're trying to attack, then attack
          else if sourceSprite in @fieldSprites
            console.log "Attempting to attack with card #{sourceSprite.card._id}"
            @battle.emitUseCardEvent sourceSprite.card._id, {card:cardId}, (err) =>
              console.log err if err?
          break
      # TODO:  go through hero tokens and see if they're casting on heroes

    onCardDropped: (sprite) ->
      corners = []
      corners.push sprite.position
      corners.push {x:sprite.position.x,y:sprite.position.y+sprite.height}
      corners.push {x:sprite.position.x+sprite.width,y:sprite.position.y+sprite.height}
      corners.push {x:sprite.position.x+sprite.width,y:sprite.position.y}
      played = false
      for corner in corners
        if FIELD_AREA.contains(corner.x, corner.y)
          card = sprite.card
          cardClass = @cardClasses[card.class]
          @battle.emitPlayCardEvent sprite.card._id, null, (err) =>
            # Return card to source
            if err?
              console.log err
              sprite.tween.start()
            else
              console.log "Played card "+sprite.card._id
              # Position the card onto the field
              @removeInteractions sprite
              @putCardOnField sprite.card
              # If there is a rush ability then set the targeting source as the sprite
              if cardClass.rushAbility?
                sprite.dropTween = null
                @setTargetingSource(@getTokenSprite(sprite.card))
          played = true
          break
      if not played
        sprite.tween.start()

    removeInteractions: (cardSprite) -> cardSprite.removeAllInteractions()

    update: ->
      if @targetingSprite?
        @.removeChild @targetingSprite
        @targetingSprite = null
      if @stage?
        if @dragSprite?
          pos = @stage.getMousePosition().clone()
          pos.x -= @dragOffset.x
          pos.y -= @dragOffset.y
          @dragSprite.position = pos
        else if @targetingSource?
          # Draw arrow to target
          pos = @stage.getMousePosition().clone()
          sourcePos = {x:@targetingSource.position.x + @targetingSource.width/2, y:@targetingSource.position.y + @targetingSource.height/2}
          @targetingSprite = @createTargetingSprite sourcePos, pos
          @.addChild @targetingSprite

    setTargetingSource: (sprite) ->
      @targetingSource = sprite

    getHandPositionAt: (idx) -> return {x:HAND_ORIGIN.x + (@getCardWidth() + HAND_PADDING) * idx, y:HAND_ORIGIN.y - @getCardHeight()}
    getOpenFieldPosition: -> return {x:FIELD_ORIGIN.x + (@getCardWidth() + FIELD_PADDING) * @fieldSprites.length, y: FIELD_ORIGIN.y}
    getOpenEnemyFieldPosition: -> return {x:ENEMY_FIELD_ORIGIN.x + (@getCardWidth() + FIELD_PADDING) * @enemyFieldSprites.length, y: ENEMY_FIELD_ORIGIN.y}
    getOpenHandPosition: -> return @getHandPositionAt(@handSprites.length)

    getCardHeight: ->
      for id, sprite of @cardSprites
        return sprite.height
      return 0
    getCardWidth: ->
      for id, sprite of @cardSprites
        return sprite.width
      return 0

    getTokenSprite: (card) ->
      sprite = @tokenSprites[card._id]
      if not sprite?
        sprite = new GUI.CardToken card, @cardClasses[card.class]
        sprite.card = card
        sprite.cardSprite = @getCardSprite(card)
        @tokenSprites[card._id] = sprite
        @tokenSpriteLayer.addChild sprite
      return sprite

    getCardSprite: (card) ->
      sprite = @cardSprites[card._id]
      if not sprite?
        sprite = @buildSpriteForCard(card)
        sprite.card = card
        @cardSprites[card._id] = sprite
        @cardSpriteLayer.addChild sprite
      return sprite

    createTargetingSprite: (start, end) ->
      # TODO: Make this an arrow
      s = new PIXI.Graphics()
      s.beginFill()
      s.lineStyle 10, 0x000000, 1.0
      s.moveTo start.x, start.y
      s.lineTo end.x, end.y
      s.endFill()
      return s

    buildSpriteForCard: (card) -> new GUI.Card @cardClasses[card.class], card.damage, card.health, card.status
