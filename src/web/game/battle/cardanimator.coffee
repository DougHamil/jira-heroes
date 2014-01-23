define ['battle/animation', 'battle/battlecard', 'battle/playerhand', 'jquery', 'gui', 'engine', 'util', 'pixi'], (Animation, BattleCard, PlayerHand, $, GUI, engine, Util) ->
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
      @cards = {}
      @cardSpriteLayer = new PIXI.DisplayObjectContainer()
      @tokenSpriteLayer = new PIXI.DisplayObjectContainer()
      @.addChild @tokenSpriteLayer
      @.addChild @cardSpriteLayer
      @playerHand = new PlayerHand HAND_ORIGIN, HAND_PADDING, DEFAULT_TWEEN_TIME
      anim = new Animation()
      for card in @battle.getCardsInHand()
        @addCard(card)
        anim.addAnimationStep(@putCardInHand(card, true), 'card-in-hand-'+card._id)
      anim.play()
      anim.on 'complete-step', (step) -> console.log step
      engine.updateCallbacks.push => @update()
      document.body.onmouseup = =>
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
      return null

    putCardInHand: (card, animate) ->
      animate = true if not animate?  # Default to animate
      battleCard = @getBattleCard(card)
      return @playerHand.addCard battleCard, animate

    update: ->

    getBattleCard: (card) ->
      if card._id?
        card = card._id
      return @cards[card]
    addCard: (card) ->
      battleCard = new BattleCard @cardClasses[card.class], card
      @cards[battleCard.getCardId()] = battleCard
      @cardSpriteLayer.addChild battleCard.getCardSprite()
      @tokenSpriteLayer.addChild battleCard.getTokenSprite()
