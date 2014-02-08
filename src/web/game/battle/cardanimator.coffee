define ['battle/fx/basic_target', 'battle/payloads/factory', 'battle/animation', 'battle/battlehero', 'battle/battlecard', 'battle/playerfield', 'battle/playerhand', 'jquery', 'gui', 'engine', 'util', 'pixi'], ( BasicTargetFx, PayloadFactory, Animation, BattleHero, BattleCard, PlayerField, PlayerHand, $, GUI, engine, Util) ->
  DISCARD_ORIGIN = {x:-200, y: 0}
  DEFAULT_TWEEN_TIME = 200
  PLAYER_HERO_POSITION = {x:engine.WIDTH - GUI.HeroToken.Width - 40, y: 400}
  PLAYER_HERO_ABILITY_POSITION = {x:engine.WIDTH - GUI.HeroToken.Width - 40, y: 400 + GUI.HeroToken.Height + 20}
  ENEMY_HERO_POSITION = {x:engine.WIDTH - GUI.HeroToken.Width - 40, y: 240}
  PLAYER_FIELD_CONFIG =
    animationTime: 500
    hoverOffset: {x:GUI.CardToken.Width + 20, y:0}
    fieldArea: new PIXI.Rectangle(0, 0, engine.WIDTH - 20, 160)
    origin: {x:20, y:engine.HEIGHT/2}
    padding: 20
    interactionEnabled:true
  ENEMY_FIELD_CONFIG =
    animationTime: 500
    hoverOffset: {x:GUI.CardToken.Width + 20, y:0}
    fieldArea: new PIXI.Rectangle(0, 0, engine.WIDTH - 20, 160)
    origin: {x:20, y:engine.HEIGHT/2 - 160}
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
      @animationQueue = []
      @activeAnimation = new Animation()
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
      for card in @battle.getCardsInHand()
        @addCard(card)
        @putCardInHand(card, false)
      for cardId in @battle.getEnemyCardsInHand()
        @addCardId cardId
        @putCardInEnemyHand(cardId, false)
      for card in @battle.getCardsOnField()
        @addCard(card)
        @putCardOnField(card, false)
      for card in @battle.getEnemyCardsOnField()
        @addCard(card)
        @putCardOnEnemyField(card, false)
      @playerHand.on 'card-dropped', (battleCard, position) => @onCardDropped(battleCard, position)
      @playerHand.on 'card-target', (battleCard, position) => @onCardTarget(battleCard, position)
      @playerField.on 'token-target', (battleCard, position) => @onTokenTarget(battleCard, position)
      engine.updateCallbacks.push => @update()
      document.body.onmouseup = => @onMouseUp()
      @battle.on 'action', (actions) => @handleActions(actions)

    animateAction: (action) ->
      switch action.type
        when 'energy'
          if action.player is @battle.getPlayerId()
            @playerEnergyIcon.setEnergy(@battle.getEnergy())
            tween = Util.scaleSpriteTween @playerEnergyIcon, 2, 200
            animation = new Animation()
            animation.addTweenStep tween
            animation.addAnimationStep =>
              tween = Util.scaleSpriteTween @playerEnergyIcon, 0.5, 200
              anim = new Animation()
              anim.addTweenStep tween
              return anim
            return animation
        when 'draw-card'
          animation = new Animation()
          if action.player is @userId
            animation.addAnimationStep => @putCardInHand(action.card, true)
          else
            animation.addAnimationStep => @putCardInEnemyHand(action.card, true)
          return animation
        when 'destroy'
          return @getBattleObject(action.target).animateDestroyed()
        when 'discard-card'
          return @discardCard action.card
      if action.target?
        target = @getBattleObject(action.target)
        if target?
          return target.animateAction(action)
      else if action.hero?
        target = @getBattleObject(action.hero)
        if target?
          return target.animateAction(action)
      return null

    handleActions: (actions) ->
      for action in actions
        @preprocessAction(action)
      animation = new Animation()
      payloads = PayloadFactory.processActions(@battle, actions)
      for payload in payloads
        if payload.animate?
          animation.addAnimationStep payload.animate(@, @battle)
      @enqueueAnimation animation

    preprocessAction:(action) ->
      action.animated = false
      switch action.type
        when 'draw-card'
          if action.player is @userId
            @addCard(@battle.getCard(action.card))
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
      animation.addAnimationStep battleCard.moveCardTo(DISCARD_ORIGIN, DEFAULT_TWEEN_TIME, false)
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
      else if @enemyHand.hasCard(battleCard)
        @enemyHand.removeCard(battleCard)
      else if @playerField.hasCard(battleCard)
        @playerField.removeCard(battleCard)
      else if @enemyField.hasCard(battleCard)
        @enemyField.removeCard(battleCard)
      return animation

    animateActions:(actions) ->
      animation = new Animation()
      for action in actions
        if not action.animated
          animation.addAnimationStep @animateAction(action)
      subAnim = new Animation()
      subAnim.addAnimationStep @playerHand.buildReorderAnimation()
      subAnim.addUnchainedAnimationStep @enemyHand.buildReorderAnimation()
      subAnim.addUnchainedAnimationStep @playerField.buildReorderAnimation()
      subAnim.addUnchainedAnimationStep @enemyField.buildReorderAnimation()
      animation.addAnimationStep subAnim
      @enqueueAnimation(animation)

    enqueueAnimation: (animation) ->
      animation.on 'complete', => @playNextAnimation()
      @animationQueue.push animation
      if not @activeAnimation? or not @activeAnimation.isPlaying
        @playNextAnimation()

    playNextAnimation: ->
      if @animationQueue.length > 0
        @activeAnimation = @animationQueue.shift()
        @activeAnimation.play()

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

    onHeroTarget: (hero, position) ->
      for targetCard in @getBattleCardsOnField()
        if targetCard.containsPoint(position)
          @battle.emitHeroAttackEvent hero.getId(), {card:targetCard.getId()}, (err) =>
            if err?
              console.log err
          return
      if @enemyHero.containsPoint(position)
        @battle.emitHeroAttackEvent hero.getId(), {hero:@enemyHero.getId()}, (err) =>
          if err?
            console.log err
        return

    onHeroAbilityTarget: (hero, position) ->
      for targetCard in @getBattleCardsOnField()
        if targetCard.containsPoint(position)
          @battle.emitUseHeroEvent hero.getId(), {card:targetCard.getId()}, (err) =>
            if err?
              console.log err
          return
      if @enemyHero.containsPoint(position)
        @battle.emitUseHeroEvent hero.getId(), {hero:@enemyHero.getId()}, (err) =>
          if err?
            console.log err
        return

    # Called when the player wants to cast the hero's ability (and it doesn't requrie a target)
    onHeroCastAbility: (hero) ->
      @battle.emitUseHeroEvent hero.getId(), (err) =>
        if err?
          console.log err

    # Called when a card is dropped from the player's hand (ie, player wants to play card)
    onCardDropped: (battleCard, position) ->
      if @playerField.containsPoint(position)
        @battle.emitPlayCardEvent battleCard.getId(), null, (err) =>
          if err?
            @playerHand.returnCardToHand(battleCard).play()
          else if battleCard.cardClass.rushAbility? and battleCard.cardClass.rushAbility.requiresTarget
            @playerField.beginTokenTarget battleCard

      else
        @playerHand.returnCardToHand(battleCard).play()

    update: ->
      @playerHand.update()
      @enemyHand.update()
      @playerField.update()
      @playerHero.update()

    onMouseUp: ->
      position = @stage.getMousePosition().clone()
      @playerHand.onMouseUp(position)
      @enemyHand.onMouseUp(position)
      @playerField.onMouseUp(position)
      @enemyField.onMouseUp(position)
      @playerHero.onMouseUp(position)

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

    getBattleHero: (hero) ->
      if hero._id?
        hero = hero._id
      if hero is @playerHero.getId()
        return @playerHero
      else if hero is @enemyHero.getId()
        return @enemyHero
      return null

    setCard:(cardId, card) ->
      battleCard = @cards[cardId]
      battleCard.setCard(@cardClasses[card.class], card)
      @cardSpriteLayer.addChild battleCard.getCardSprite()
      @tokenSpriteLayer.addChild battleCard.getTokenSprite()

    setPlayerHero: (heroModel) ->
      @playerHero = new BattleHero(heroModel, @heroClasses[heroModel.class], true, @uiLayer)
      sprite = @playerHero.getTokenSprite()
      sprite.position = PLAYER_HERO_POSITION
      abilitySprite = @playerHero.getAbilityTokenSprite()
      abilitySprite.position = PLAYER_HERO_ABILITY_POSITION
      @tokenSpriteLayer.addChild sprite
      @tokenSpriteLayer.addChild abilitySprite
      @playerHero.on 'hero-target', (hero, position) => @onHeroTarget(hero, position)
      @playerHero.on 'hero-ability-target', (hero, position) => @onHeroAbilityTarget(hero, position)
      @playerHero.on 'hero-cast-ability', (hero) => @onHeroCastAbility(hero)

    setEnemyHero: (heroModel) ->
      @enemyHero = new BattleHero(heroModel, @heroClasses[heroModel.class], false, @uiLayer)
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
    getHeroClass: (hero) -> return @heroClasses[hero.class]
    getSprite: (obj) ->
      if not obj?
        return null
      if obj._id?
        obj = obj._id
      if @playerHero.getId() is obj
        return @playerHero.getTokenSprite()
      if @enemyHero.getId() is obj
        return @enemyHero.getTokenSprite()
      if @cards[obj]?
        card = @cards[obj]
        if card.isTokenVisible()
          return card.getTokenSprite()
        else
          return card.getAvailableCardSprite()
      return null
