define ['gfx/textbutton', 'gfx/styles','util', 'engine', 'pixi', 'tween'], (TextButton, STYLES, Util, engine) ->
  ###
  # Presents cards as a grid with pages
  ###
  class PagedCardGrid extends PIXI.DisplayObjectContainer
    constructor: (@width, @height, @padding, @cardsPerRow, @rowsPerPage, @cardSprites) ->
      super
      if @cardSprites? and @cardSprites.length > 0
        cardHeight = @cardSprites[0].height
        cardWidth = @cardSprites[0].width
        @width = @cardsPerRow * cardWidth + (@cardsPerRow + 1) * @padding
        @height = @rowsPerPage * cardHeight + (@rowsPerPage + 1) * @padding
      @nextBtn = new TextButton 'Next Page'
      @prevBtn = new TextButton 'Last Page'
      @nextBtn.position = {x:@width - @nextBtn.width, y:@height + @nextBtn.height}
      @prevBtn.position = {x:0, y:@height + @prevBtn.height}
      @nextBtn.onClick => @nextPage()
      @prevBtn.onClick => @prevPage()
      @pages = []
      pageContainer = new PIXI.DisplayObjectContainer
      cardIndex = 0
      for card in @cardSprites
        pageContainer.addChild card
        xpos = @padding + ((cardIndex % @cardsPerRow) * (@padding + card.width))
        ypos = Math.floor(cardIndex / @cardsPerRow) * (@padding + card.height) + @padding
        card.position = {x:xpos, y:ypos}
        cardIndex++
        if cardIndex is (@cardsPerRow * @rowsPerPage)
          cardIndex = 0
          @pages.push pageContainer
          pageContainer = new PIXI.DisplayObjectContainer
      if cardIndex != 0
        @pages.push pageContainer
      @setPageIndex(0)

    nextPage: -> @setPageIndex (@pageIndex + 1)
    prevPage: -> @setPageIndex (@pageIndex - 1)
    setPageIndex: (index) ->
      if @pageIndex? and index >= @pages.length or index < 0 or index is @pageIndex
        return
      else
        if @pageIndex is 0
          @prevBtn.visible = true
        if @pageIndex is (@pages.length - 1)
          @nextBtn.visible = true
        if index is (@pages.length - 1)
          @nextBtn.visible = false
        else if index is 0
          @prevBtn.visible = false
        if @pageIndex?
          @.removeChild @pages[@pageIndex]
        @pageIndex = index
        @.addChild @pages[@pageIndex]
