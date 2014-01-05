define ['gfx/styles', 'util', 'pixi', 'tween'], (styles, Util) ->
  BACKGROUND_TEXTURE = PIXI.Texture.fromImage '/media/images/cards/background.png'

  ###
  # Draws everything for a card, showing the image, damage, heatlh, status, etc.
  ###
  class Card extends PIXI.DisplayObjectContainer
    constructor: (cardClass, damage, health, status) ->
      super()
      imageTexture = PIXI.Texture.fromImage cardClass.media.image

      @backgroundSprite = new PIXI.Sprite BACKGROUND_TEXTURE
      @imageSprite = new PIXI.Sprite imageTexture
      @titleText = new PIXI.Text cardClass.displayName, styles.CARD_TITLE
      @healthText = new PIXI.Text health.toString(), styles.CARD_STAT
      @damageText = new PIXI.Text damage.toString(), styles.CARD_STAT
      @description = @buildAbilityText cardClass

      @description.anchor = {x:0.5, y:0}
      @description.position = {x:@backgroundSprite.width / 2, y: @backgroundSprite.height / 2}
      @titleText.anchor = {x: 0.5, y:0}
      @titleText.position = {x:@backgroundSprite.width / 2, y: 0}
      @healthText.anchor = {x: 0.5, y:0.5}
      @healthText.position = {x:0, y: @backgroundSprite.height}
      @damageText.anchor = {x: 0.5, y:0.5}
      @damageText.position = {x:0, y: @backgroundSprite.height}
      @imageSprite.anchor = {x: 0.5, y:0}
      @imageSprite.position = {x: @backgroundSprite.width / 2, y: 0}

      @.addChild @backgroundSprite
      @.addChild @imageSprite
      @.addChild @titleText
      @.addChild @description
      @.addChild @healthText
      @.addChild @damageText

    buildAbilityText: (cardClass) ->
      parent = new PIXI.DisplayObjectContainer
      count = 0
      for ability in cardClass.abilities
        chunks = ability.text.split ' '
        string = ""
        for chunk in chunks
          # Extract a property from the metadata of the ability
          if /^<\w+>$/.test(chunk)
            prop = chunk.replace /[<>]/g, ''
            chunk = ability.data[prop]
          string += (chunk + ' ')
        text = new PIXI.Text string, styles.CARD_DESCRIPTION
        text.position = {x: 0, y: count * text.height}
        count++
        parent.addChild text
      # TODO: Figure out how to display 'traits' such as rush
      return parent


