define ['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], ($, JH, GUI, engine) ->
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
      @nextBtn = new GUI.TextButton 'Next Page'
      @prevBtn = new GUI.TextButton 'Last Page'
      @backBtn = new GUI.TextButton 'Back'

      @nextBtn.position = {x:engine.WIDTH - @nextBtn.width - 20, y:engine.HEIGHT - 200}
      @nextBtn.onClick => @nextPage()
      @prevBtn.onClick => @prevPage()
      @prevBtn.position = {x:20, y:engine.HEIGHT - 200}
      @backBtn.position = {x:20, y:engine.HEIGHT - @backBtn.height - 20}
      @backBtn.onClick => @manager.activateView 'MainMenu'

      @.addChild @heading
      @.addChild @backBtn
      @.addChild @nextBtn
      @.addChild @prevBtn

    deactivate: ->
      @myStage.removeChild @
      if JH.pointsText?
        @.removeChild JH.pointsText
      if JH.nameText?
        @.removeChild JH.nameText
      @.removeChild @pages[@pageIndex]

    nextPage: -> @setPageIndex (@pageIndex + 1)
    prevPage: -> @setPageIndex (@pageIndex - 1)
    setPageIndex: (index) ->
      if index >= @pages.length or index < 0 or index is @pageIndex
        return
      else
        if @pageIndex is 0
          @.addChild @prevBtn
        if @pageIndex is (@pages.length - 1)
          @.addChild @nextBtn
        if index is (@pages.length - 1)
          @.removeChild @nextBtn
        else if index is 0
          @.removeChild @prevBtn
        if @pageIndex?
          @.removeChild @pages[@pageIndex]
        @pageIndex = index
        @.addChild @pages[@pageIndex]

    activate: (@hero) ->
      activate = (cards) =>
        JH.cards = cards
        @pages = []
        pageContainer = new PIXI.DisplayObjectContainer
        cardIndex = 0
        for card in cards
          cardSprite = GUI.Card.FromClass card
          pageContainer.addChild cardSprite
          cardSprite.onHoverStart (card) =>
            card.scale.x += 0.1
            card.scale.y += 0.1
          cardSprite.onHoverEnd (card) =>
            card.scale.x -= 0.1
            card.scale.y -= 0.1
          xpos = CARD_PADDING + ((cardIndex % CARDS_PER_ROW) * (CARD_PADDING + cardSprite.width))
          ypos = Math.floor(cardIndex / CARDS_PER_ROW) * (CARD_PADDING + cardSprite.height)
          cardSprite.position.x = xpos
          cardSprite.position.y = ypos
          cardIndex++
          if cardIndex is (CARDS_PER_ROW * ROWS_PER_PAGE)
            pageContainer.position = PAGE_POS
            cardIndex = 0
            @pages.push pageContainer
            pageContainer = new PIXI.DisplayObjectContainer
            pageContainer.position = PAGE_POS

        if cardIndex != 0
          @pages.push pageContainer

        @setPageIndex(0)
        @.addChild JH.pointsText
        @.addChild JH.nameText
        @myStage.addChild @
      # TODO: Get first page of card data
      if not JH.cards?
        JH.GetAllCards activate
      else
        activate(JH.cards)
