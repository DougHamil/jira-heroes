define ['battle/fx/basic_target', 'battle/animation', 'battle/battlehero', 'battle/battlecard', 'battle/playerfield', 'battle/playerhand', 'jquery', 'gui', 'engine', 'util', 'pixi'], (BasicTargetFx, Animation, BattleHero, BattleCard, PlayerField, PlayerHand, $, GUI, engine, Util) ->
  DISCARD_ORIGIN = {x:-200, y: 0}
  DEFAULT_TWEEN_TIME = 200
  PLAYER_HERO_POSITION = {x:engine.WIDTH - GUI.HeroToken.Width - 20, y: 400}
  ENEMY_HERO_POSITION = {x:engine.WIDTH - GUI.HeroToken.Width - 20, y: 160}
  PLAYER_FIELD_CONFIG =
    animationTime: 500
    hoverOffset: {x:GUI.CardToken.Width + 20, y:0}
    fieldArea: new PIXI.Rectangle(0, 0, engine.WIDTH - 20, 220)
    origin: {x:20, y:400}
    padding: 20
  ENEMY_FIELD_CONFIG =
    animationTime: 500
    hoverOffset: {x:GUI.CardToken.Width + 20, y:0}
    fieldArea: new PIXI.Rectangle(0, 0, engine.WIDTH - 20, 220)
    origin: {x:20, y:160}
    padding: 20
  ENEMY_HAND_CONFIG =
    handHoverOffset: 50
    origin: {x:20, y: -100}
    padding: 20
    animationTime: DEFAULT_TWEEN_TIME
  PLAYER_HAND_CONFIG =
    animationTime: DEFAULT_TWEEN_TIME
    origin: {x:20, y:engine.HEIGHT + 50 - GUI.Card.Height}
    padding: 20
    hoverOffset: {x: 0, y: -50}

  ###
  # Manages all card sprites in the battle by positioning and animating them
  # as the battle unfolds.
  ###
  class CardAnimator extends PIXI.DisplayObjectContainer
    constructor: (@heroClasses, @cardClasses, @userId, @battle) ->
      super
      @cards = {}
      @cardSpriteLayer = new PIXI.DisplayObjectContainer()
      @tokenSpriteLayer = new PIXI.DisplayObjectContainer()
      @uiLayer = new PIXI.DisplayObjectContainer()
      @.addChild @tokenSpriteLayer
      @.addChild @cardSpriteLayer
      @.addChild @uiLayer
      @playerHand = new PlayerHand PLAYER_HAND_CONFIG, @uiLayer
      @enemyHand = new PlayerHand ENEMY_HAND_CONFIG, @uiLayer
      @playerField = new PlayerField PLAYER_FIELD_CONFIG, @uiLayer
      @enemyField = new PlayerField ENEMY_FIELD_CONFIG, @uiLayer
      @setPlayerHero(@battle.getHero())
      @setEnemyHero(@battle.getEnemyHero())
      anim = new Animation()
      for card in @battle.getCardsInHand()
        @addCard(card)
        anim.addAnimationStep(@putCardInHand(card, false), 'card-in-hand-'+card._id)
      for cardId in @battle.getEnemyCardsInHand()
        @addCardId cardId
        anim.addAnimationStep(@putCardInEnemyHand(cardId, false), 'enemy-card-in-hand-'+cardId)
      for card in @battle.getCardsOnField()
        @addCard(card)
        anim.addAnimationStep(@putCardOnField(card, false), 'card-on-field-'+card._id)
      for card in @battle.getEnemyCardsOnField()
        @addCard(card)
        anim.addAnimationStep(@putCardOnEnemyField(card, false), 'enemy-card-on-field'+card._id)
      anim.play()
      @playerHand.on 'card-dropped', (battleCard, position) => @onCardDropped(battleCard, position)
      @playerHand.on 'card-target', (battleCard, position) => @onCardTarget(battleCard, position)
      @playerField.on 'token-target', (battleCard, position) => @onTokenTarget(battleCard, position)
      engine.updateCallbacks.push => @update()
      document.body.onmouseup = => @onMouseUp()
      @battle.on 'action', (actions) => @animateActions(actions)
      @battle.on 'your-turn', (actions) => @animateActions(actions)
      @battle.on 'opponent-turn', (actions) => @animateActions(actions)

    animateActions: (actions) ->
      animation = new Animation()
      for action in actions
        @animateAction(action, animation)
      animation.play()

    processActions: (actions) ->
      payload = {}
      for action in actions
        @processAction(action, payload)
      return payload

    processAction: (payload, action) ->
      switch action.type
        when 'draw-card'

    animateAction: (action, animation) ->
      switch action.type
        when 'draw-card'
          if action.player is @userId
            @addCard(action.card)
            animation.addAnimationStep @putCardInHand(action.card, true), 'draw-card'
          else
            @addCardId action.card
            animation.addAnimationStep @putCardInEnemyHand(action.card, true), 'enemy-draw-card'
        when 'play-card'
          if action.player is @userId
            animation.addAnimationStep @putCardOnField(action.card, true), 'play-card'
            animation.addAnimationStep @playerHand.buildReorderAnimation(), 'hand-reorder'
          else
            # On play card, we'll finally know what the card data is for the enemy
            @setCard action.card._id, action.card
            animation.addAnimationStep @putCardOnEnemyField(action.card, true), 'enemy-play-card'
            animation.addAnimationStep @enemyHand.buildReorderAnimation(), 'enemy-hand-reorder'
        when 'discard-card'
          animation.addAnimationStep @discardCard(@battle.getCard(action.card)), 'discard-card'
          if action.player is @userId
            animation.addAnimationStep @playerHand.buildReorderAnimation(), 'hand-reorder'
          else
            animation.addAnimationStep @enemyHand.buildReorderAnimation(), 'enemy-hand-reorder'
        when 'attack'
          animation.addAnimationStep @attack(@battle.getCard(action.source), @battle.getCard(action.target))
        when 'cast-card'
          # Enemy casting a card will finally reveal the card data
          if action.player isnt @userId
            @setCard action.card._id, action.card
          animation.addAnimationStep @castCard(action.card, action.targets), 'cast-card'
          if action.player is @userId
            animation.addAnimationStep @playerHand.buildReorderAnimation(), 'hand-reorder'
          else
            animation.addAnimationStep @enemyHand.buildReorderAnimation(), 'enemy-hand-reorder'

    attack: (source, target) ->
      battleCardSource = @getBattleCard(source)
      battleCardTarget = @getBattleCard(target)

    castCard: (card, targets) ->
      battleCard = @getBattleCard(card)
      battleCard.setCardInteractive(false)
      battleCard.setTokenInteractive(false)
      animation = new Animation()
      if @enemyHand.hasCard(battleCard)
        @enemyHand.removeCard(battleCard)
        animation.addAnimationStep battleCard.flipCard(true)
      else if @playerHand.hasCard(battleCard)
        @playerHand.removeCard(battleCard)
      # TODO: Build spell FX classes to create animations for spells
      if targets.length > 0
        castFx = new BasicTargetFx(card, targets)
        animation.addAnimationStep castFx.buildAnimation(@), 'cast-spell'
      animation.addAnimationStep ->
        battleCard.moveCardTo(DISCARD_ORIGIN, DEFAULT_TWEEN_TIME, false)
      return animation

    discardCard: (card) ->
      # TODO: Fancy discard graphic
      battleCard = @getBattleCard(card)
      battleCard.setCardInteractive(false)
      battleCard.setTokenInteractive(false)
      if @playerHand.hasCard(battleCard)
        @playerHand.removeCard(battleCard)
        return battleCard.moveCardTo(DISCARD_ORIGIN, DEFAULT_TWEEN_TIME, false)
      else if @enemyHand.hasCard(battleCard)
        @enemyHand.removeCard(battleCard)
        return battleCard.moveCardTo(DISCARD_ORIGIN, DEFAULT_TWEEN_TIME, false)
      # Ideally cards are already removed from the field via the destroy-card action
      else if @playerField.hasCard(battleCard)
        @playerField.removeCard(battleCard)
        return battleCard.moveTokenTo(DISCARD_ORIGIN, DEFAULT_TWEEN_TIME, false)
      else if @enemyField.hasCard(battleCard)
        @enemyField.removeCard(battleCard)
        return battleCard.moveTokenTo(DISCARD_ORIGIN, DEFAULT_TWEEN_TIME, false)
      return null

    putCardOnEnemyField: (card, animate) ->
      animate = true if not animate?
      battleCard = @getBattleCard(card)
      if @enemyHand.hasCard(battleCard)
        @enemyHand.removeCard(battleCard)
        battleCard.setTokenPosition(battleCard.getFlippedCardSprite().position)
      return @enemyField.addCard battleCard, animate, false

    putCardOnField: (card, animate) ->
      animate = true if not animate?
      battleCard = @getBattleCard(card)
      if @playerHand.hasCard(battleCard)
        @playerHand.removeCard(battleCard)
        battleCard.setTokenPosition(battleCard.getCardSprite().position)
      return @playerField.addCard battleCard, animate, true

    putCardInEnemyHand: (cardId, animate) ->
      animate = true if not animate? # Default to animate
      battleCard = @getBattleCard(cardId)
      return @enemyHand.addCard battleCard, animate, false

    putCardInHand: (card, animate) ->
      animate = true if not animate?  # Default to animate
      battleCard = @getBattleCard(card)
      return @playerHand.addCard battleCard, animate, true

    onTokenTarget: (battleCard, position) ->
      for targetCard in @getBattleCardsOnField()
        if targetCard.containsPoint(position)
          @battle.emitUseCardEvent battleCard.getId(), {card:targetCard.getId()}, (err) =>
            if err?
              console.log err
          return
      if @playerHero.containsPoint(position)
        @battle.emitUseCardEvent battleCard.getId(), {hero:@playerHero.getId()}, (err) =>
          if err?
            console.log err
        return
      if @enemyHero.containsPoint(position)
        @battle.emitUseCardEvent battleCard.getId(), {hero:@enemyHero.getId()}, (err) =>
          if err?
            console.log err
        return

    onCardTarget: (battleCard, position) ->
      if battleCard.requiresTarget()
        for targetCard in @getBattleCardsOnField()
          if targetCard.containsPoint(position)
            @battle.emitPlayCardEvent battleCard.getId(), {card:targetCard.getId()}, (err) =>
              if err?
                console.log err
            return
        if @playerHero.containsPoint(position)
          @battle.emitPlayCardEvent battleCard.getId(), {hero:@playerHero.getId()}, (err) =>
            if err?
              console.log err
          return
        if @enemyHero.containsPoint(position)
          @battle.emitPlayCardEvent battleCard.getId(), {hero:@enemyHero.getId()}, (err) =>
            if err?
              console.log err
          return

    # Called when a card is dropped from the player's hand (ie, player wants to play card)
    onCardDropped: (battleCard, position) ->
      if @playerField.containsPoint(position)
        @battle.emitPlayCardEvent battleCard.getId(), null, (err) =>
          if err?
            console.log err
            @playerHand.returnCardToHand(battleCard).play()
      else
        @playerHand.returnCardToHand(battleCard).play()

    update: ->
      @playerHand.update()
      @enemyHand.update()
      @playerField.update()

    onMouseUp: ->
      position = @stage.getMousePosition().clone()
      @playerHand.onMouseUp(position)
      @enemyHand.onMouseUp(position)
      @playerField.onMouseUp(position)
      @enemyField.onMouseUp(position)

    getBattleCardsOnField: -> return @playerField.getBattleCards().concat(@enemyField.getBattleCards())

    getBattleCard: (card) ->
      if card._id?
        card = card._id
      return @cards[card]

    setCard:(cardId, card) ->
      battleCard = @cards[cardId]
      battleCard.setCard(@cardClasses[card.class], card)
      @cardSpriteLayer.addChild battleCard.getCardSprite()
      @tokenSpriteLayer.addChild battleCard.getTokenSprite()

    setPlayerHero: (heroModel) ->
      @playerHero = new BattleHero(heroModel, @heroClasses[heroModel.class], true)
      sprite = @playerHero.getTokenSprite()
      sprite.position = PLAYER_HERO_POSITION
      @tokenSpriteLayer.addChild sprite

    setEnemyHero: (heroModel) ->
      @enemyHero = new BattleHero(heroModel, @heroClasses[heroModel.class], false)
      sprite = @enemyHero.getTokenSprite()
      sprite.position = ENEMY_HERO_POSITION
      @tokenSpriteLayer.addChild sprite

    addCardId:(cardId) ->
      battleCard = new BattleCard(cardId, null,null)
      @cards[cardId] = battleCard
      @cardSpriteLayer.addChild battleCard.getFlippedCardSprite()

    addCard: (card) ->
      battleCard = new BattleCard card._id, @cardClasses[card.class], card
      @cards[battleCard.getCardId()] = battleCard
      @cardSpriteLayer.addChild battleCard.getFlippedCardSprite()
      @cardSpriteLayer.addChild battleCard.getCardSprite()
      @tokenSpriteLayer.addChild battleCard.getTokenSprite()

    getSprite: (obj) ->
      if obj._id?
        if @cards[obj._id]
          card = @cards[obj._id]
          if card.isTokenVisible()
            return card.getTokenSprite()
          else
            return card.getAvailableCardSprite()
        if @playerHero.getId() is obj._id
          return @playerHero.getTokenSprite()
        if @enemyHero.getId() is obj._id
          return @enemyHero.getTokenSprite()
      return null
