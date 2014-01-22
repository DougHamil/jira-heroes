define ['jquery', 'gui', 'engine', 'util', 'pixi'], ($, GUI, engine, Util) ->
  DECK_ORIGIN = {x:engine.WIDTH + 200, y: engine.HEIGHT}
  ENEMY_DECK_ORIGIN = {x:engine.WIDTH + 200, y: 100}
  DISCARD_ORIGIN = {x:-200, y: 0}
  FIELD_PADDING = 50
  ENEMY_HAND_ORIGIN = {x:20, y:-100}
  HAND_ANIM_TIME = 1000
  HAND_HOVER_OFFSET = 50
  HAND_ORIGIN = {x:20, y:engine.HEIGHT + HAND_HOVER_OFFSET - GUI.Card.Height}
  HAND_PADDING = 20
  HOVER_ANIM_TIME = 200
  DEFAULT_TWEEN_TIME = 400
  TOKEN_CARD_OFFSET = 10
  FIELD_AREA = new PIXI.Rectangle 10, 400, engine.WIDTH - 20, 220
  FIELD_ORIGIN = {x:20, y:FIELD_AREA.y + 10}
  ENEMY_FIELD_ORIGIN = {x:20, y: 160}
  HERO_ORIGIN = {x:engine.WIDTH - GUI.HeroToken.Width - 20, y:FIELD_ORIGIN.y}
  ENEMY_HERO_ORIGIN = {x:engine.WIDTH - GUI.HeroToken.Width - 20, y:ENEMY_FIELD_ORIGIN.y}

  ###
  # Manages all card sprites in the battle by positioning and animating them
  # as the battle unfolds.
  ###
  class CardAnimator extends PIXI.DisplayObjectContainer
    constructor: (@heroClasses, @cardClasses, @userId, @battle) ->
      super
      @cardSpriteLayer = new PIXI.DisplayObjectContainer()
      @tokenSpriteLayer = new PIXI.DisplayObjectContainer()
      @.addChild @tokenSpriteLayer
      @.addChild @cardSpriteLayer
      @flippedCardSprites = {}
      @cardSprites = {}
      @tokenSprites = {}
      @cardTokens = {}
      @heroTokens = {}
      @buildHeroTokens(@battle.getHero(), @battle.getEnemyHero(), @heroClasses)
      @handSpriteRow = new GUI.OrderedSpriteRow(HAND_ORIGIN, GUI.Card.Width, HAND_PADDING, HAND_ANIM_TIME)
      @fieldSpriteRow = new GUI.OrderedSpriteRow(FIELD_ORIGIN, GUI.CardToken.Width, FIELD_PADDING, DEFAULT_TWEEN_TIME)
      @enemyHandSpriteRow = new GUI.OrderedSpriteRow(ENEMY_HAND_ORIGIN, GUI.Card.Width, HAND_PADDING, HAND_ANIM_TIME)
      @enemyFieldSpriteRow = new GUI.OrderedSpriteRow(ENEMY_FIELD_ORIGIN, GUI.CardToken.Width, FIELD_PADDING, DEFAULT_TWEEN_TIME)
      for card in @battle.getCardsInHand()
        @putCardInHand card, false
      for card in @battle.getEnemyCardsInHand()
        @putEnemyCardInHand card, false
      for card in @battle.getCardsOnField()
        @putCardOnField card, false
      for card in @battle.getEnemyCardsOnField()
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
      @battle.on 'action-cast-card', (action) => @onCastCardAction(action)
      @battle.on 'action-damage', (action) => @onDamageAction(action)
      @battle.on 'action-heal', (action) => @onHealAction(action)
      @battle.on 'action-overheal', (action) => @onHealAction(action)
      @battle.on 'action-discard-card', (action) => @onDiscardCardAction(action)
      @battle.on 'action-status-add', (action) => @onStatusAction(action)
      @battle.on 'action-status-remove', (action) => @onStatusAction(action)
      @battle.on 'action-add-modifier', (action) => @updateToken(action.target)
      @battle.on 'action-remove-modifier', (action) => @updateToken(action.target)

    buildHeroTokens: (hero, enemyHero, heroClasses) ->
      console.log heroClasses
      @heroTokens[hero._id] = new GUI.HeroToken hero, heroClasses[hero.class]
      @heroTokens[enemyHero._id] = new GUI.HeroToken enemyHero, heroClasses[enemyHero.class]
      @heroTokens[hero._id].position = HERO_ORIGIN
      @heroTokens[enemyHero._id].position = ENEMY_HERO_ORIGIN
      @tokenSpriteLayer.addChild @heroTokens[hero._id]
      @tokenSpriteLayer.addChild @heroTokens[enemyHero._id]

    updateToken: (tokenId) ->
      card = @battle.getCard(tokenId)
      tokenSprite = null
      if card?
        tokenSprite = @getTokenSprite(card)
      else
        card = @battle.getHero(tokenId)
        tokenSprite = @heroTokens[tokenId]
      if tokenSprite?
        console.log card
        tokenSprite.setTaunt(('taunt' in card.getStatus())) if tokenSprite? and card?
        tokenSprite.setFrozen(('frozen' in card.getStatus())) if tokenSprite? and card?

    onStatusAction: (action) ->
      @updateToken(action.target)

    onDiscardCardAction: (action) ->
      # TODO: Instead handle destroy action and show FX for destroying card
      cardSprite = @getCardSprite @battle.getCard(action.card)
      console.log cardSprite.card
      @putCardInDiscard cardSprite.card

    updateHeroHealth: (heroId) ->
      heroSprite = @heroTokens[heroId]
      if heroSprite?
        heroSprite.setHealth(@battle.getHero(heroId).health)

    updateCardHealth: (cardId) ->
      cardSprite = @cardSprites[cardId]
      tokenSprite = @tokenSprites[cardId]
      if cardSprite?
        cardSprite.setHealth(@battle.getCard(cardId).health)
      if tokenSprite
        tokenSprite.setHealth(@battle.getCard(cardId).health)

    onDamageAction: (action) ->
      @updateCardHealth(action.target) # TODO: Show damage FX
      @updateHeroHealth(action.target)
    onHealAction: (action) ->
      @updateCardHealth(action.target) # TODO: Show heal FX
      @updateHeroHealth(action.target)

    onPlayCardAction: (action) ->
      if action.player isnt @userId
        @putEnemyCardOnField action.card

    onCastCardAction: (action) ->
      # TODO: Show some card casting animation

    onEndTurnAction: (action) ->
      @fixHandPositions()
      @fixFieldPositions()

    onDrawCardAction: (action) ->
      if action.player is @userId
        @putCardInHand(action.card)
      else
        # NOTE: action.card will only be the card's ID
        @putEnemyCardInHand(action.card)

    setFieldTokenInteraction: (tokenSprite, isTargetSource) ->
      cardPos = Util.clone(tokenSprite.position)
      cardPos.x += tokenSprite.width + TOKEN_CARD_OFFSET
      tokenSprite.cardSprite.position = cardPos
      tokenSprite.cardSprite.visible = false
      # Show card when token is hovered
      tokenSprite.onHoverStart =>
        tokenSprite.cardSprite.visible = true
      tokenSprite.onHoverEnd =>
        tokenSprite.cardSprite.visible = false
      if isTargetSource
        tokenSprite.onMouseDown => @setTargetingSource(tokenSprite)

    placeFieldToken: (spriteRow, cardSprite, tokenSprite, isTargetSource, animate) ->
      addInteraction = (sprite) => =>
        @setFieldTokenInteraction(sprite, isTargetSource)
        sprite.visible = true
      position = spriteRow.addSprite tokenSprite, false
      tokenSprite.visible = false
      if animate
        # Animate card sprite going to token position
        tween = Util.spriteTween(cardSprite, cardSprite.position, position, DEFAULT_TWEEN_TIME)
        cardSprite.tween = tween
        tween.start()
        tween.onComplete addInteraction(tokenSprite)
      else
        addInteraction(tokenSprite)()

    putCardInDiscard: (card, animate) ->
      animate = true if not animate?
      cardSprite = @getCardSprite card
      tokenSprite = @getTokenSprite card
      position = @getDiscardPosition()
      # Animate token to discard
      if @fieldSpriteRow.hasSprite(tokenSprite) or @enemyFieldSpriteRow.hasSprite(tokenSprite)
        tokenSprite.tween = Util.spriteTween tokenSprite, tokenSprite.position, position, DEFAULT_TWEEN_TIME
        tokenSprite.tween.onComplete => tokenSprite.visible = false
        tokenSprite.tween.start()
        tokenSprite.removeAllInteractions()
        cardSprite.visible = false
      # Animate hand to discard
      else if @handSpriteRow.hasSprite(cardSprite) or @enemyHandSpriteRow.hasSprite(cardSprite)
        cardSprite.tween = Util.spriteTween cardSprite, cardSprite.position, position, DEFAULT_TWEEN_TIME
        cardSprite.tween.onComplete => cardSprite.visible = false
        cardSprite.tween.start()
        cardSprite.removeAllInteractions()
        tokenSprite.visible = false

      @fieldSpriteRow.removeSprite(tokenSprite)
      @enemyFieldSpriteRow.removeSprite(tokenSprite)
      if @handSpriteRow.hasSprite(cardSprite)
        @handSpriteRow.removeSprite(cardSprite)
      if @enemyHandSpriteRow.hasSprite(cardSprite)
        @enemyHandSpriteRow.removeSprite(cardSprite)

    putEnemyCardOnField: (card, animate) ->
      animate = true if not animate?
      cardSprite = @getCardSprite card
      tokenSprite = @getTokenSprite card
      if animate
        handSprite = @flippedCardSprites[card._id]
        # Hide the flipped card if it is shown in the enemy's hand
        if handSprite?
          if @enemyHandSpriteRow.hasSprite(handSprite)
            cardSprite.position = handSprite.position
            @cardSpriteLayer.removeChild handSprite
            @enemyHandSpriteRow.removeSprite handSprite
      @placeFieldToken @enemyFieldSpriteRow, cardSprite, tokenSprite, false, animate
      @tokenSpriteLayer.addChild tokenSprite
      @cardSpriteLayer.addChild cardSprite

    putCardOnField: (card, animate) ->
      # Default to animate
      animate = true if not animate?
      cardSprite = @getCardSprite card
      tokenSprite = @getTokenSprite card
      @placeFieldToken @fieldSpriteRow, cardSprite, tokenSprite, true, animate
      @handSpriteRow.removeSprite cardSprite
      @tokenSpriteLayer.addChild tokenSprite
      @cardSpriteLayer.addChild cardSprite

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
        console.log cardClass.playAbility
        # If this card has a cast ability, then it's a spell card, so pick a target
        if cardClass.playAbility? and (not cardClass.playAbility.requiresTarget? or cardClass.playAbility.requiresTarget)
          @setTargetingSource(sprite)
        else
          if sprite.tween?
            sprite.tween.stop()
            @dragOffset = @stage.getMousePosition().clone()
            @dragOffset.x -= sprite.position.x
            @dragOffset.y -= sprite.position.y
            @dragSprite = sprite
            @cardSpriteLayer.removeChild @dragSprite
            @cardSpriteLayer.addChild @dragSprite
      sprite.onMouseUp =>
        if sprite.tween?
          sprite.tween.stop()
        if @dragSprite is sprite
          @dragSprite = null
          tween = Util.spriteTween sprite, sprite.position, from, HOVER_ANIM_TIME
          sprite.tween = tween
          @onCardDropped @stage.getMousePosition().clone(), sprite

    putEnemyCardInHand: (cardId, animate) ->
      animate = true if not animate?
      sprite = if @flippedCardSprites[cardId]? then @flippedCardSprites[cardId] else new GUI.FlippedCard()
      @flippedCardSprites[cardId] = sprite
      sprite.cardId = cardId
      sprite.sourcePosition = @enemyHandSpriteRow.addSprite sprite, animate
      @cardSpriteLayer.addChild sprite

    putCardInHand: (card, animate) ->
      # Default to animate
      animate = true if not animate?
      sprite = @getCardSprite card
      if animate and sprite.position.x is 0 and sprite.position.y is 0
        sprite.position = Util.clone(DECK_ORIGIN)
      sprite.sourcePosition = @handSpriteRow.addSprite sprite, animate, => @setHandInteraction(sprite)
      @cardSpriteLayer.addChild sprite

    fixHandPositions: ->
      removeInteractions = (sprite) => @removeInteractions(sprite)
      setInteractions = (sprite) => => @setHandInteraction(sprite)
      @handSpriteRow.reorder removeInteractions, setInteractions
      @enemyHandSpriteRow.reorder()

    fixFieldPositions: ->
      removeInteractions = (sprite) => @removeInteractions(sprite)
      setInteractions = (sprite) => => @setFieldTokenInteraction(sprite, true)
      setEnemyInteractions = (sprite) => => @setFieldTokenInteraction(sprite, false)
      @fieldSpriteRow.reorder removeInteractions, setInteractions
      @enemyFieldSpriteRow.reorder removeInteractions, setEnemyInteractions

    onTargeted: (sourceSprite, targetPosition) ->
      # TODO: Clean this up, specifically the repeated functions for emiting events on target
      foundTarget = false
      for cardId, tokenSprite of @tokenSprites
        if tokenSprite.contains(targetPosition)
          # If this is a spell card being played from the hand, then play the spell with the target
          if @handSpriteRow.hasSprite(sourceSprite)
            foundTarget = true
            @battle.emitPlayCardEvent sourceSprite.card._id, {card:cardId}, (err) =>
              if err?
                # TODO: Depending on error, provide feedback (not enough energy, not your turn, etc)
                console.log err
                if sourceSprite.dropTween?
                  sourceSprite.dropTween.start()
                else if sourceSprite.tween?
                  sourceSprite.tween.start()
          # If this is a token sprite and we're trying to attack, then attack
          else if @fieldSpriteRow.hasSprite(sourceSprite)
            foundTarget = true
            @battle.emitUseCardEvent sourceSprite.card._id, {card:cardId}, (err) =>
              if err?
                # TODO: Depending on error, provide feedback (not enough energy, not your turn, etc)
                console.log err
                if sourceSprite.dropTween?
                  sourceSprite.dropTween.start()
          break
      # Targeting hero?
      for heroId, heroTokenSprite of @heroTokens
        if heroTokenSprite.contains(targetPosition)
          console.log heroId
          # If this is a spell card being played from the hand, then play the spell with the target
          if @handSpriteRow.hasSprite(sourceSprite)
            foundTarget = true
            @battle.emitPlayCardEvent sourceSprite.card._id, {hero:heroId}, (err) =>
              if err?
                # TODO: Depending on error, provide feedback (not enough energy, not your turn, etc)
                console.log err
                if sourceSprite.dropTween?
                  sourceSprite.dropTween.start()
                else if sourceSprite.tween?
                  sourceSprite.tween.start()
          # If this is a token sprite and we're trying to attack, then attack
          else if @fieldSpriteRow.hasSprite(sourceSprite)
            foundTarget = true
            @battle.emitUseCardEvent sourceSprite.card._id, {hero:heroId}, (err) =>
              if err?
                # TODO: Depending on error, provide feedback (not enough energy, not your turn, etc)
                console.log err
                if sourceSprite.dropTween?
                  sourceSprite.dropTween.start()
          break
      return foundTarget

    onCardDropped: (mousePosition, sprite) ->
      played = false
      if FIELD_AREA.contains(mousePosition.x, mousePosition.y)
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
            if not sprite.card.playAbility?
              @putCardOnField sprite.card
              # If there is a rush ability then set the targeting source as the sprite
              if cardClass.rushAbility?
                sprite.dropTween = null
                @setTargetingSource(@getTokenSprite(sprite.card))
        played = true
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

    getDiscardPosition: -> return DISCARD_ORIGIN

    getTokenSprite: (card) ->
      sprite = @tokenSprites[card._id]
      if not sprite?
        sprite = new GUI.CardToken card, @cardClasses[card.class]
        sprite.card = card
        sprite.cardSprite = @getCardSprite(card)
        @tokenSprites[card._id] = sprite
      return sprite

    getCardSprite: (card) ->
      sprite = @cardSprites[card._id]
      if not sprite?
        sprite = @buildSpriteForCard(card)
        sprite.card = card
        @cardSprites[card._id] = sprite
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
