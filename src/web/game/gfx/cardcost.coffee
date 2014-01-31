define ['gfx/styles', 'gfx/card', 'gfx/glyphtext', 'util', 'pixi', 'tween'], (styles, Card, GlyphText, Util) ->
  class CardCost extends PIXI.DisplayObjectContainer
    constructor: (cost, canAfford, isPurchased) ->
      super
      costString = ""
      for type, amount of cost
        switch type
          when 'storyPoints'
            costString += "#{amount} <storypoint> "
          when 'bugsReported'
            costString += "#{amount} <bugsreported> "
          when 'bugsClosed'
            costString += "#{amount} <bugsclosed> "
      @costText = new GlyphText costString
      @purchasedText = new PIXI.Text "Purchased", styles.TEXT
      @costText.anchor = {x:0.5, y:0.5}
      @purchasedText.anchor = {x:0.5, y:0.5}
      @costText.position = {x:-@costText.width/2, y:-@costText.height/2}

      @purchasedBg = new PIXI.Graphics()
      @purchasedBg.beginFill styles.CARD_PURCHASED_COLOR
      @purchasedBg.drawRect -Card.Width/2, -@purchasedText.height/2, Card.Width, @purchasedText.height
      @purchasedBg.endFill()

      @cantAffordBg = new PIXI.Graphics()
      @cantAffordBg.beginFill styles.CARD_CANT_AFFORD_COLOR
      @cantAffordBg.drawRect -Card.Width/2, -@purchasedText.height/2, Card.Width, @purchasedText.height
      @cantAffordBg.endFill()

      @.addChild @purchasedBg
      @.addChild @cantAffordBg
      @.addChild @costText
      @.addChild @purchasedText

      @update(canAfford, isPurchased)

      @width = Card.Width
      @height = @purchasedText.height

    update: (canAfford, isPurchased) ->
      @purchasedBg.visible = false
      @cantAffordBg.visible = false
      if isPurchased or canAfford
        @purchasedBg.visible = true
        @cantAffordBg.visible = false
      else if canAfford
        @purchasedBg.visible = true
      else
        @cantAffordBg.visible = true
      @purchasedText.visible = isPurchased
      @costText.visible = !isPurchased
