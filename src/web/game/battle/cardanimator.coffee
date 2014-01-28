define ['battle/animation', 'battle/battlecard', 'battle/playerhand', 'jquery', 'gui', 'engine', 'util', 'pixi'], (Animation, BattleCard, PlayerHand, $, GUI, engine, Util) ->
  DECK_ORIGIN = {x:engine.WIDTH + 200, y: engine.HEIGHT}
  ENEMY_DECK_ORIGIN = {x:engine.WIDTH + 200, y: 100}
  DISCARD_ORIGIN = {x:-200, y: 0}
  FIELD_PADDING = 50
  HOVER_ANIM_TIME = 200
  DEFAULT_TWEEN_TIME = 200
  TOKEN_CARD_OFFSET = 10
  FIELD_AREA = new PIXI.Rectangle 10, 400, engine.WIDTH - 20, 220
  FIELD_ORIGIN = {x:20, y:FIELD_AREA.y + 10}
  ENEMY_FIELD_ORIGIN = {x:20, y: 160}
  HERO_ORIGIN = {x:engine.WIDTH - GUI.HeroToken.Width - 20, y:FIELD_ORIGIN.y}
  ENEMY_HERO_ORIGIN = {x:engine.WIDTH - GUI.HeroToken.Width - 20, y:ENEMY_FIELD_ORIGIN.y}
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
      anim = new Animation()
      for card in @battle.getCardsInHand()
        @addCard(card)
        anim.addAnimationStep(@putCardInHand(card, true), 'card-in-hand-'+card._id)
      for cardId in @battle.getEnemyCardsInHand()
        @addCardId cardId
        anim.addAnimationStep(@putCardInEnemyHand(cardId, true), 'enemy-card-in-hand-'+cardId)
      anim.play()
      anim.on 'complete-step', (step) -> console.log step
      @playerHand.on 'card-dropped', (battleCard, position) => @onCardDropped(battleCard, position)
      @playerHand.on 'card-target', (battleCard, position) => @onCardTarget(battleCard, position)
      engine.updateCallbacks.push => @update()
      document.body.onmouseup = => @onMouseUp()
      @battle.on 'action', (actions) => @animateActions(actions)
      @battle.on 'your-turn', (actions) => @animateActions(actions)
      ###
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
      ###

    animateActions: (actions) ->
      animation = new Animation()
      for action in actions
        animation.addAnimationStep @buildAnimationForAction(action), 'action-'+action.type
      animation.play()

    buildAnimationForAction: (action) ->
      switch action.type
        when 'draw-card'
          if action.player is @userId
            @addCard(action.card)
            battleCard = @getBattleCard(action.card)
            return @playerHand.addCard battleCard, true
        when 'play-card'
          if action.player is @userId
            # TODO: Move card to field
            @putCardOnField(action.card, true)
          else
            # On play card, we'll finally know what the card data is for the enemy
            @setCard action.card._id, action.card
            @putCardOnField(action.card, true)
      return null

    putCardOnField: (card, animate) ->

    putCardInEnemyHand: (cardId, animate) ->
      animate = true if not animate? # Default to animate
      battleCard = @getBattleCard(cardId)
      return @enemyHand.addCard battleCard, animate, false

    putCardInHand: (card, animate) ->
      animate = true if not animate?  # Default to animate
      battleCard = @getBattleCard(card)
      return @playerHand.addCard battleCard, animate, true

    onCardTarget: (battleCard, position) ->
      # TODO: Determine the target at the given position
      @battle.emitPlayCardEvent battleCard.getId(), null, (err) =>
        if err?
          @playerHand.returnCardToHand(battleCard).play()

    # Called when a card is dropped from the player's hand (ie, player wants to play card)
    onCardDropped: (battleCard, position) ->
      if FIELD_AREA.contains(position.x, position.y)
        @battle.emitPlayCardEvent battleCard.getId(), null, (err) =>
          if err?
            @playerHand.returnCardToHand(battleCard).play()

    update: ->
      @playerHand.update()
      @enemyHand.update()

    onMouseUp: ->
      position = @stage.getMousePosition().clone()
      @playerHand.onMouseUp(position)
      @enemyHand.onMouseUp(position)

    getBattleCard: (card) ->
      if card._id?
        card = card._id
      return @cards[card]

    setCard:(cardId, card) ->
      battleCard = @cards[cardId]
      battleCard.setCard(@cardClasses[card.class], card)
      @cardSpriteLayer.addChild battleCard.getCardSprite()
      @tokenSpriteLayer.addChild battleCard.getTokenSprite()

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
