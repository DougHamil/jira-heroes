define ['battle/payloads/factory', 'battle/animation', 'battle/battlehero', 'battle/battlecard', 'battle/playerfield', 'battle/playerhand', 'jquery', 'gui', 'engine', 'util', 'pixi'], (PayloadFactory, Animation, BattleHero, BattleCard, PlayerField, PlayerHand, $, GUI, engine, Util) ->
  PLAYER_DECK_ORIGIN = {x:engine.WIDTH + GUI.Card.Width/2, y:engine.HEIGHT - GUI.Card.Height}
  ENEMY_DECK_ORIGIN = {x:engine.WIDTH + GUI.Card.Width/2, y:GUI.Card.Height}
  DISCARD_ORIGIN = {x:-200, y: 0}
  DEFAULT_TWEEN_TIME = 200
  PLAYER_HERO_POSITION = {x:engine.WIDTH - GUI.HeroToken.Width/2 - 40, y: 400 + GUI.HeroToken.Height/2}
  PLAYER_HERO_ABILITY_POSITION = {x:engine.WIDTH - GUI.HeroToken.Width - 40, y: 400 + GUI.HeroToken.Height + 20}
  ENEMY_HERO_POSITION = {x:engine.WIDTH - GUI.HeroToken.Width/2 - 40, y: 240 + GUI.HeroToken.Height/2}
  ENEMY_HERO_ABILITY_POSITION = {x:engine.WIDTH - GUI.HeroToken.Width - 40, y: 240 - GUI.HeroToken.Height - 20}
  PLAYER_FIELD_CONFIG =
    animationTime: 500
    hoverOffset: {x:GUI.CardToken.Width + 20, y:0}
    fieldArea: new PIXI.Rectangle(0, 0, engine.WIDTH - 20, 160)
    origin: {x:20 + GUI.CardToken.Width/2, y:engine.HEIGHT/2 + GUI.CardToken.Height/2}
    padding: 20
    interactionEnabled:true
  ENEMY_FIELD_CONFIG =
    animationTime: 500
    hoverOffset: {x:GUI.CardToken.Width + 20, y:0}
    fieldArea: new PIXI.Rectangle(0, 0, engine.WIDTH - 20, 160)
    origin: {x:20 + GUI.CardToken.Width/2, y:engine.HEIGHT/2 - 160 + GUI.CardToken.Height/2}
    padding: 20
    interactionEnabled:false
  ENEMY_HAND_CONFIG =
    handHoverOffset: 50
    origin: {x:20 + GUI.Card.Width/2, y: -100 + GUI.Card.Height/2}
    padding: 20
    animationTime: DEFAULT_TWEEN_TIME
  PLAYER_HAND_CONFIG =
    animationTime: DEFAULT_TWEEN_TIME
    origin: {x:20 + GUI.Card.Width/2, y:engine.HEIGHT + 50 - GUI.Card.Height/2}
    padding: 20
    hoverOffset: {x: 0, y: -70}

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
      @errorDisplay = new GUI.Error()
      @yourTurnGraphic = new GUI.YourTurn()
      @cardSpriteLayer = new PIXI.DisplayObjectContainer()
      @tokenSpriteLayer = new PIXI.DisplayObjectContainer()
      @uiLayer = new PIXI.DisplayObjectContainer()
      @.addChild @tokenSpriteLayer
      @.addChild @cardSpriteLayer
      @.addChild @uiLayer
      @.addChild engine.fxLayer # All particles will be drawn on this layer
      @endTurnTab = new GUI.EndTurnButton(true)
      @endTurnTab.position = {x:engine.WIDTH/2, y:0}
      @endTurnTab.onClick => @battle.emitEndTurnEvent()
      @endTurnTab.setIsYourTurn(@battle.isYourTurn())
      if @battle.isYourTurn()
        @endTurnTab.setNoMoreMoves(!@battle.hasValidMoves())
      @yourTurnGraphic.onAnimationComplete => @endTurnTab.setIsYourTurn(@battle.isYourTurn())
      @uiLayer.addChild @endTurnTab
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
      @errorDisplay.position = {x:engine.WIDTH/2, y:engine.HEIGHT/2}
      @uiLayer.addChild @errorDisplay
      @uiLayer.addChild @yourTurnGraphic

    deactivate: ->
      document.body.onmouseup = ->

    animateAction: (action) ->
      switch action.type
        when 'energy'
          if action.player is @battle.getPlayerId()
            @playerEnergyIcon.setEnergy(@battle.getEnergy())
        when 'draw-card'
          animation = new Animation()
          if action.player is @userId
            animation.addAnimationStep =>
              bCard = @getBattleCard(action.card)
              bCard.setCardPosition(PLAYER_DECK_ORIGIN)
              bCard.setTokenPosition(PLAYER_DECK_ORIGIN)
              return @putCardInHand(action.card, true)
          else
            animation.addAnimationStep =>
              bCard = @getBattleCard(action.card)
              bCard.setCardPosition(ENEMY_DECK_ORIGIN)
              @putCardInEnemyHand(action.card, true)
          return animation
        when 'destroy'
          return @getBattleObject(action.target).animateDestroyed()
        when 'start-turn'
          if action.player is @battle.getPlayerId()
            return @yourTurnGraphic.animate()
          else
            anim = new Animation()
            anim.on 'complete', => @endTurnTab.setIsYourTurn(@battle.isYourTurn())
            return anim
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
      payloads = PayloadFactory.processActions(@battle, [].concat(actions))
      for payload in payloads
        if payload.animate?
          animation.addAnimationStep payload.animate(@, @battle)
      animation.addAnimationStep @buildReorderAnimation(actions)
      anim = new Animation()
      anim.on 'start', =>
        if @battle.isYourTurn() and not @battle.hasValidMoves()
          @endTurnTab.setNoMoreMoves(true)
      animation.addAnimationStep anim
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
        when 'discard-card'
          @discardCard(action.card)

    discardCard: (card) ->
      battleCard = @getBattleCard(card)
      if not battleCard?
        return null
      #battleCard.setCardInteractive(false)
      #battleCard.setTokenInteractive(false)
      if @playerHand.hasCard(battleCard)
        @playerHand.removeCard(battleCard)
      else if @enemyHand.hasCard(battleCard)
        @enemyHand.removeCard(battleCard)
      else if @playerField.hasCard(battleCard)
        @playerField.removeCard(battleCard)
      else if @enemyField.hasCard(battleCard)
        @enemyField.removeCard(battleCard)

    animateActions:(actions) ->
      animation = new Animation()
      for action in actions
        if not action.animated
          animation.addAnimationStep @animateAction(action)
      @enqueueAnimation(animation)

    buildReorderAnimation: (actions)->
      =>
        animation = new Animation()
        animation.addAnimationStep @playerHand.buildReorderAnimation()
        animation.addAnimationStep @enemyHand.buildReorderAnimation()
        animation.addAnimationStep @playerField.buildReorderAnimation()
        animation.addAnimationStep @enemyField.buildReorderAnimation()
        return animation
        ###
        animation = new Animation()
        animSet = {}
        for action in actions
          switch action.type
            when 'discard-card'
              @buildReorderForCard(animSet, @getBattleCard(action.card))
              @discardCard action.card
            when 'play-card'
              @buildReorderForCard(animSet, @getBattleCard(action.card))
        index = 0
        for key, anim of animSet
          if index is 0
            animation.addAnimationStep anim
          else
            animation.addUnchainedAnimationStep anim
          index++
        return animation
        ###

    buildReorderForCard: (animSet, battleCard) ->
      if @playerHand.hasCard(battleCard)
        animSet.playerHand = @playerHand.buildReorderAnimation()
      else if @playerField.hasCard(battleCard)
        animSet.playerField = @playerField.buildReorderAnimation()
      else if @enemyHand.hasCard(battleCard)
        animSet.enemyHand = @enemyHand.buildReorderAnimation()
      else if @enemyField.hasCard(battleCard)
        animSet.enemyField = @enemyField.buildReorderAnimation()
      console.log animSet

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
        reorder = true
      animation = new Animation()
      animation.addAnimationStep @enemyField.addCard(battleCard, animate, false)
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
              @errorDisplay.showError(err)
          return
      if @playerHero.containsPoint(position)
        @battle.emitUseCardEvent battleCard.getId(), {hero:@playerHero.getId()}, (err) =>
          if err?
            console.log err
            @errorDisplay.showError(err)
        return
      if @enemyHero.containsPoint(position)
        @battle.emitUseCardEvent battleCard.getId(), {hero:@enemyHero.getId()}, (err) =>
          if err?
            console.log err
            @errorDisplay.showError(err)
        return

    onCardTarget: (battleCard, position) ->
      if battleCard.requiresTarget()
        for targetCard in @getBattleCardsOnField()
          if targetCard.containsPoint(position)
            @battle.emitPlayCardEvent battleCard.getId(), {card:targetCard.getId()}, (err) =>
              if err?
                console.log err
                @errorDisplay.showError(err)
            return
        if @playerHero.containsPoint(position)
          @battle.emitPlayCardEvent battleCard.getId(), {hero:@playerHero.getId()}, (err) =>
            if err?
              console.log err
              @errorDisplay.showError(err)
          return
        if @enemyHero.containsPoint(position)
          @battle.emitPlayCardEvent battleCard.getId(), {hero:@enemyHero.getId()}, (err) =>
            if err?
              console.log err
              @errorDisplay.showError(err)
          return

    onHeroTarget: (hero, position) ->
      for targetCard in @getBattleCardsOnField()
        if targetCard.containsPoint(position)
          @battle.emitHeroAttackEvent {card:targetCard.getId()}, (err) =>
            if err?
              console.log err
              @errorDisplay.showError(err)
          return
      if @enemyHero.containsPoint(position)
        @battle.emitHeroAttackEvent {hero:@enemyHero.getId()}, (err) =>
          if err?
            console.log err
            @errorDisplay.showError(err)
        return

    onHeroAbilityTarget: (hero, position) ->
      for targetCard in @getBattleCardsOnField()
        if targetCard.containsPoint(position)
          @battle.emitUseHeroEvent {card:targetCard.getId()}, (err) =>
            if err?
              console.log err
              @errorDisplay.showError(err)
          return
      if @enemyHero.containsPoint(position)
        @battle.emitUseHeroEvent {hero:@enemyHero.getId()}, (err) =>
          if err?
            console.log err
            @errorDisplay.showError(err)
        return

    # Called when the player wants to cast the hero's ability (and it doesn't requrie a target)
    onHeroCastAbility: (hero) ->
      @battle.emitUseHeroEvent null, (err) =>
        if err?
          console.log err
          @errorDisplay.showError(err)

    # Called when a card is dropped from the player's hand (ie, player wants to play card)
    onCardDropped: (battleCard, position) ->
      if @playerField.containsPoint(position)
        @battle.emitPlayCardEvent battleCard.getId(), null, (err) =>
          if err?
            @errorDisplay.showError(err)
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
      @endTurnTab.update()

    onMouseUp: ->
      position = @stage.getMousePosition().clone()
      @playerHand.onMouseUp(position)
      @enemyHand.onMouseUp(position)
      @playerField.onMouseUp(position)
      @enemyField.onMouseUp(position)
      @playerHero.onMouseUp(position)
      @endTurnTab.onMouseUp(position)

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
      abilityPopup = abilitySprite.getPopupSprite()
      abilityPopup.position = Util.clone PLAYER_HERO_ABILITY_POSITION
      abilityPopup.position.x -= (abilityPopup.width + 20)
      @tokenSpriteLayer.addChild sprite
      @tokenSpriteLayer.addChild abilitySprite
      @uiLayer.addChild abilityPopup
      @playerHero.on 'hero-target', (hero, position) => @onHeroTarget(hero, position)
      @playerHero.on 'hero-ability-target', (hero, position) => @onHeroAbilityTarget(hero, position)
      @playerHero.on 'hero-cast-ability', (hero) => @onHeroCastAbility(hero)

    setEnemyHero: (heroModel) ->
      @enemyHero = new BattleHero(heroModel, @heroClasses[heroModel.class], false, @uiLayer)
      sprite = @enemyHero.getTokenSprite()
      sprite.position = ENEMY_HERO_POSITION
      abilitySprite = @enemyHero.getAbilityTokenSprite()
      abilitySprite.position = ENEMY_HERO_ABILITY_POSITION
      abilityPopup = abilitySprite.getPopupSprite()
      abilityPopup.position = Util.clone ENEMY_HERO_ABILITY_POSITION
      abilityPopup.position.x -= (abilityPopup.width + 20)
      @tokenSpriteLayer.addChild sprite
      @tokenSpriteLayer.addChild abilitySprite
      @uiLayer.addChild abilityPopup

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
