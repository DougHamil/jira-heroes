define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->
  COST_SPRITE_PADDING = 10
  PAGE_POS =
    x: 50
    y: 100
  CARD_PADDING = 50
  CARDS_PER_ROW = 4
  ROWS_PER_PAGE = 2

  class Library extends PIXI.DisplayObjectContainer
    constructor: (@manager, @myStage) ->
      super
      @heading = new PIXI.Text 'Library', GUI.STYLES.HEADING
      @backBtn = new GUI.TextButton 'Back'

      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'MainMenu'

      @.addChild @heading
      @.addChild @backBtn

    deactivate: ->
      @myStage.removeChild @
      if JH.pointsText?
        @.removeChild JH.pointsText
      if JH.nameText?
        @.removeChild JH.nameText
      if @cardPicker?
        @.removeChild @cardPicker
        @cardPicker = null

    activate: (@hero) ->
      activate = (cards) =>
        @updateLibrary JH.user.library
        JH.cards = cards
        allCardIds = (id for id, card of JH.cards)
        @cardPicker = new GUI.CardPicker allCardIds, JH.cards
        @cardPicker.position = {x:20, y:100}
        @cardsById = {}
        @cardSprites = {}
        @cardPicker.onCardPicked (cardId) =>
          if not @library[cardId]?
            JH.AddCardToUserLibrary cardId, @onCardBought(cardId), @onCardBuyFail(cardId)
        for cardId, card of cards
          cardSprite = @cardPicker.getSprite(cardId)
          @cardSprites[cardId] = cardSprite
          @cardsById[card._id] = card
          cardSprite.onHoverStart (card) =>
            card.scale.x += 0.1
            card.scale.y += 0.1
          cardSprite.onHoverEnd (card) =>
            card.scale.x -= 0.1
            card.scale.y -= 0.1
        @addCostSprites JH.user, @library, @cardSprites, @cardsById
        @.addChild @cardPicker
        @.addChild JH.pointsText
        @.addChild JH.nameText
        @myStage.addChild @

      if not JH.cards?
        JH.GetAllCards activate
      else
        activate(JH.cards)

    updateLibrary: (userLibrary) ->
      @library = {}
      for cardId in userLibrary
        @library[cardId] = true

    onCardBuyFail: (cardId) ->
      =>
        console.log arguments
        console.log "Card buying failed for card #{cardId}"

    onCardBought: (cardId) ->
      =>
        JH.GetUser (user) =>
          JH.user = user
          @updateLibrary user.library
          @addCostSprites()
          JH.pointsText.setText "#{user.points} <coin>"
          @cardSprites[cardId].onClick ->

    updateCostSprite: (cardId) ->
      card = @cardsById[cardId]
      cardSprite = @cardSprites[cardId]
      costSprite = @createCostSprite(cardSprite, card.cost, JH.user.points >= card.cost, @library[cardId]?)
      costSprite.position = {x:cardSprite.width/2, y:cardSprite.height/2 - costSprite.height}
      if cardSprite.costSprite?
        cardSprite.removeChild cardSprite.costSprite
      cardSprite.costSprite = costSprite
      cardSprite.addChild costSprite

    addCostSprites: ->
      for cardId, card of @cardsById
        @updateCostSprite cardId

    createCostSprite: (cardSprite, cost, canAfford, isOwned) ->
      container = new PIXI.DisplayObjectContainer
      bgcolor = if canAfford or isOwned then 0x00BB00 else 0xBB0000
      text = null
      if isOwned
        text = new PIXI.Text "Purchased", GUI.STYLES.TEXT
      else
        text = new GUI.GlyphText "#{cost} <coin>"
        text.position = {x:-text.width/2,y:-text.height/2}
      bg = new PIXI.Graphics()
      bg.beginFill bgcolor
      bg.width = cardSprite.width
      bg.height = text.height + COST_SPRITE_PADDING
      bg.drawRect -bg.width/2, -bg.height/2, bg.width, bg.height
      text.anchor = {x:0.5, y:0.5}
      container.addChild bg
      container.addChild text
      container.width = bg.width
      container.height = bg.height
      return container
