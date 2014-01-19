define ['gfx/damageicon', 'gfx/healthicon','gfx/energyicon','gfx/styles', 'util', 'pixi', 'tween'], (DamageIcon, HealthIcon, EnergyIcon, styles, Util) ->
  IMAGE_SIZE =
    width: 64
    height: 64
  CARD_SIZE =
    width: 150
    height: 214
  IMAGE_POS =
    x: CARD_SIZE.width / 2
    y: 22
  IMAGE_PATH = '/media/images/cards/'
  BACKGROUND_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'background.png'
  MISSING_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'missing.png'

  ###
  # Draws everything for a card, showing the image, damage, heatlh, status, etc.
  ###
  class Card extends PIXI.DisplayObjectContainer
    @FromClass: (cardClass) ->
      return new Card cardClass, cardClass.damage, cardClass.health, []
    constructor: (cardClass, damage, health, status) ->
      super()
      imageTexture = PIXI.Texture.fromImage IMAGE_PATH + cardClass.media.image
      if not imageTexture.baseTexture.hasLoaded
        console.log "Error loading #{cardClass.media.image}"
        imageTexture = MISSING_TEXTURE

      @backgroundSprite = new PIXI.Sprite BACKGROUND_TEXTURE
      @backgroundSprite.width = CARD_SIZE.width
      @backgroundSprite.height = CARD_SIZE.height
      @imageSprite = new PIXI.Sprite imageTexture
      @imageSprite.width = IMAGE_SIZE.width
      @imageSprite.height = IMAGE_SIZE.height
      @titleText = new PIXI.Text cardClass.displayName, styles.CARD_TITLE
      @healthIcon = new HealthIcon health
      @damageIcon = new DamageIcon damage
      @energyIcon = new EnergyIcon cardClass.energy
      @description = @buildAbilityText cardClass

      @description.anchor = {x:0.5, y:0}
      @description.position = {x:@backgroundSprite.width / 2, y: @backgroundSprite.height / 2}
      @titleText.anchor = {x: 0.5, y:0}
      @titleText.position = {x:@backgroundSprite.width / 2, y: 0}
      @healthIcon.position = {x:@backgroundSprite.width - @healthIcon.width, y: @backgroundSprite.height - @healthIcon.height}
      @damageIcon.position = {x:0, y: @backgroundSprite.height - @damageIcon.height}
      @energyIcon.position = {x:-@energyIcon.width/2, y:-@energyIcon.height/2}
      @imageSprite.anchor = {x: 0.5, y:0}
      @imageSprite.position = {x: IMAGE_POS.x, y: IMAGE_POS.y}

      @.addChild @backgroundSprite
      @.addChild @imageSprite
      @.addChild @titleText
      @.addChild @description
      @.addChild @healthIcon
      @.addChild @damageIcon
      @.addChild @energyIcon
      @width = CARD_SIZE.width
      @height = CARD_SIZE.height
      @.hitArea = new PIXI.Rectangle(0, 0, @width, @height)
      @.interactive = true

    setHealth: (health) -> @healthIcon.setHealth(health)
    setDamage: (damage) -> @damageIcon.setDamage(damage)
    setEnergy: (energy) -> @energyIcon.setEnergy(energy)
    onHoverStart: (cb) -> @.mouseover = => cb @ if cb?
    onHoverEnd: (cb) -> @.mouseout = => cb @ if cb?
    onClick: (cb) -> @.click = => cb @ if cb?
    onMouseDown: (cb) -> @.mousedown = => cb @ if cb?
    onMouseUp: (cb) -> @.mouseup = =>cb @ if cb?

    removeAllInteractions: ->
      @.mouseover = null
      @.mouseout = null
      @.click = null
      @.mousedown = null
      @.mouseup = null

    buildAbilityText: (cardClass) ->
      parent = new PIXI.DisplayObjectContainer
      count = 0
      for ability in cardClass.passiveAbilities
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


