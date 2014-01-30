define ['battle/fx/basic_target', 'battle/payloads/factory', 'battle/animation', 'battle/battlehero', 'battle/battlecard', 'battle/playerfield', 'battle/playerhand', 'jquery', 'gui', 'engine', 'util', 'pixi'], ( BasicTargetFx, PayloadFactory, Animation, BattleHero, BattleCard, PlayerField, PlayerHand, $, GUI, engine, Util) ->
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
    interactionEnabled:true
  ENEMY_FIELD_CONFIG =
    animationTime: 500
    hoverOffset: {x:GUI.CardToken.Width + 20, y:0}
    fieldArea: new PIXI.Rectangle(0, 0, engine.WIDTH - 20, 220)
    origin: {x:20, y:160}
    padding: 20
    interactionEnabled:false
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
      @playerEnergyIcon = new GUI.EnergyIcon @battle.getEnergy()
      @playerEnergyIcon.anchor = {x:1,y:0}
      @playerEnergyIcon.position = {x:engine.WIDTH - @playerEnergyIcon.width, y:0}
      @uiLayer.addChild @playerEnergyIcon
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
      for action in actions
        @processAction(action)
      animation = new Animation()
      payloads = PayloadFactory.processActions(@battle, actions)
      for payload in payloads
        if payload.animate?
          animation.addAnimationStep payload.animate(@, @battle)
      animation.play()

    processAction:(action) ->
      switch action.type
        when 'energy'
          if action.player is @battle.getPlayerId()
            @playerEnergyIcon.setEnergy(@battle.getEnergy())
        when 'draw-card'
          if action.player is @userId
            @addCard(action.card)
          else
            @addCardId action.card
        when 'play-card'
          if action.player isnt @userId
            # On play card, we'll finally know what the card data is for the enemy
            @setCard action.card._id, action.card
        when 'cast-card'
          # Enemy casting a card will finally reveal the card data
          if action.player isnt @userId
            @setCard action.card._id, action.card

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

    discardCard: (card, animation) ->
      animation = new Animation() if not animation?
      battleCard = @getBattleCard(card)
      if not battleCard?
        return null
      battleCard.setCardInteractive(false)
      battleCard.setTokenInteractive(false)
      if @playerHand.hasCard(battleCard)
        @playerHand.removeCard(battleCard)
        animation.addAnimationStep @playerHand.buildReorderAnimation()
      else if @enemyHand.hasCard(battleCard)
        @enemyHand.removeCard(battleCard)
        animation.addAnimationStep @enemyHand.buildReorderAnimation()
      else if @playerField.hasCard(battleCard)
        @playerField.removeCard(battleCard)
        animation.addAnimationStep @playerField.buildReorderAnimation()
      else if @enemyField.hasCard(battleCard)
        @enemyField.removeCard(battleCard)
        animation.addAnimationStep @enemyField.buildReorderAnimation()
      return animation

    animateAction: (action) ->
      switch action.type
        when 'energy'
          if action.player is @battle.getPlayerId()
            tween = Util.scaleSpriteTween @playerEnergyIcon, 2, 200
            animation = new Animation()
            animation.addTweenStep tween
            animation.addAnimationStep =>
              tween = Util.scaleSpriteTween @playerEnergyIcon, 0.5, 200
              anim = new Animation()
              anim.addTweenStep tween
              return anim
            return animation
      return null

    putCardOnEnemyField: (card, animate) ->
      animate = true if not animate?
      battleCard = @getBattleCard(card)
      reorder = false
      if @enemyHand.hasCard(battleCard)
        @enemyHand.removeCard(battleCard)
        battleCard.setTokenPosition(battleCard.getFlippedCardSprite().position)
        reorder = true
      animation = new Animation()
      animation.addAnimationStep @enemyField.addCard(battleCard, animate, false)
      if reorder and animate
        animation.addUnchainedAnimationStep @enemyHand.buildReorderAnimation()
      return animation

    putCardOnField: (card, animate) ->
      animate = true if not animate?
      battleCard = @getBattleCard(card)
      reorder = false
      if @playerHand.hasCard(battleCard)
        @playerHand.removeCard(battleCard)
        battleCard.setTokenPosition(battleCard.getCardSprite().position)
        reorder = true
      animation = new Animation()
      animation.addAnimationStep @playerField.addCard(battleCard, animate, true)
      if animate and reorder
        animation.addUnchainedAnimationStep @playerHand.buildReorderAnimation()
      return animation

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

    getBattleObject: (id) ->
      if id._id?
        id = id._id
      if @playerHero.getId() is id
        return @playerHero
      else if @enemyHero.getId() is id
        return @enemyHero
      else
        return @getBattleCard(id)
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

    getCardClass: (card) -> return @cardClasses[card.class]
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
