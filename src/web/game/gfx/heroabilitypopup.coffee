define ['gfx/energyicon','gfx/styles', 'util', 'pixi', 'tween'], (EnergyIcon, styles, Util) ->
  CARD_SIZE =
    width: 150
    height: 225
  CARD_SCALE =
    x: (CARD_SIZE.width / 512)
    y: (CARD_SIZE.height / 768)
  IMAGE_SCALE =
    x: 0.8
    y: 0.8
  IMAGE_SIZE =
    width: 512 * (CARD_SIZE.width / 512) * IMAGE_SCALE.x
    height: 512 * (CARD_SIZE.height / 768) * IMAGE_SCALE.y
  IMAGE_MASK =
    width: IMAGE_SIZE.width
    height: IMAGE_SIZE.height - 60
  IMAGE_POS =
    x: (CARD_SIZE.width - IMAGE_SIZE.width)/2
    y: 10
  SHADOW_OFFSET =
    x: 5
    y: 5
  IMAGE_PATH = '/media/images/cards/'
  BACKGROUND_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'card_front.png'
  OVERLAY_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'card_overlay.png'
  SHADOW_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'card_shadow.png'
  MISSING_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'missing.png'
  ABILITY_IMAGE_PATH = '/media/images/heroes/'

  ###
  # Draws everything for a card, showing the image, damage, heatlh, status, etc.
  ###
  class HeroAbilityPopup extends PIXI.DisplayObjectContainer
    @Width: CARD_SIZE.width
    @Height: CARD_SIZE.height
    @FromClass: (heroClass) ->
      return new HeroAbilityPopup heroClass, heroClass.ability
    constructor: (heroClass, heroAbility) ->
      super()
      imageTexture = PIXI.Texture.fromImage ABILITY_IMAGE_PATH + heroAbility.media.image
      @shadowSprite = new PIXI.Sprite SHADOW_TEXTURE
      @shadowSprite.width = CARD_SIZE.width
      @shadowSprite.height = CARD_SIZE.height
      @shadowSprite.position = SHADOW_OFFSET
      @backgroundSprite = new PIXI.Sprite BACKGROUND_TEXTURE
      @backgroundSprite.width = CARD_SIZE.width
      @backgroundSprite.height = CARD_SIZE.height
      @imageSprite = new PIXI.Sprite imageTexture
      @imageSprite.width = IMAGE_SIZE.width
      @imageSprite.height = IMAGE_SIZE.height
      @overlaySprite = new PIXI.Sprite OVERLAY_TEXTURE
      @overlaySprite.width = CARD_SIZE.width
      @overlaySprite.height = CARD_SIZE.height
      @titleText = new PIXI.Text heroAbility.displayName, styles.CARD_TITLE
      if @titleText.width >= @backgroundSprite.width - 20
        @titleText.width = @backgroundSprite.width - 20
      @energyIcon = new EnergyIcon heroAbility.energy, heroAbility.energy
      @description = @buildAbilityText heroAbility
      @description.position = {x:15, y: @backgroundSprite.height / 2 + 30}
      @titleText.anchor = {x: 0.5, y:0}
      @titleText.position = {x:@backgroundSprite.width / 2, y: 395 * CARD_SCALE.y}
      @energyIcon.position = {x:0, y:0}
      @imageSprite.position = {x: IMAGE_POS.x, y: IMAGE_POS.y}

      @.addChild @shadowSprite
      @.addChild @backgroundSprite
      @.addChild @imageSprite
      @.addChild @overlaySprite
      @.addChild @titleText
      @.addChild @description
      @.addChild @energyIcon

      @width = CARD_SIZE.width
      @height = CARD_SIZE.height
      @.hitArea = new PIXI.Rectangle(0, 0, @width, @height)
      @.interactive = true

    contains: (point) ->
      point = {x:point.x - @position.x, y:point.y - @position.y}
      return @visible and @hitArea.contains(point.x, point.y)

    buildAbilityText: (heroAbility) ->
      parent = new PIXI.DisplayObjectContainer
      text = @_buildAbilityText heroAbility.text, heroAbility.data
      parent.addChild text
      return parent

    _buildAbilityText: (abilityText, abilityData) ->
      chunks = abilityText.split ' '
      string = ""
      regex = /^(.*)<(.+)>$/
      for chunk in chunks
        # Extract a property from the metadata of the ability
        if regex.test(chunk)
          match = regex.exec(chunk)
          chunk.replace regex, ''
          propString = match[2]
          props = propString.split '.'
          datum = abilityData
          for prop in props
            datum = datum[prop]
          chunk = datum
          if not chunk?
            chunk = "[UNKNOWN: #{propString}]"
          chunk = match[1] + chunk
        string += (chunk + ' ')
      return new PIXI.Text string, styles.CARD_DESCRIPTION

    getCenterPosition: ->
      return {x:@.position.x + @width/2, y:@.position.y + @height/2}
