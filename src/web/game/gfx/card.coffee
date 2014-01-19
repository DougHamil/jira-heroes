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
      @energyIcon = new EnergyIcon cardClass.energy
      @description = @buildAbilityText cardClass
      @description.position = {x:5, y: @backgroundSprite.height / 2 + 20}
      @titleText.anchor = {x: 0.5, y:0}
      @titleText.position = {x:@backgroundSprite.width / 2, y: 0}
      @energyIcon.position = {x:-@energyIcon.width/2, y:-@energyIcon.height/2}
      @imageSprite.anchor = {x: 0.5, y:0}
      @imageSprite.position = {x: IMAGE_POS.x, y: IMAGE_POS.y}

      @.addChild @backgroundSprite
      @.addChild @imageSprite
      @.addChild @titleText
      @.addChild @description
      @.addChild @energyIcon

      # Damage and health only appear for non-spell cards
      if not cardClass.playAbility?
        @healthIcon = new HealthIcon health
        @damageIcon = new DamageIcon damage
        @healthIcon.position = {x:@backgroundSprite.width - @healthIcon.width, y: @backgroundSprite.height - @healthIcon.height}
        @damageIcon.position = {x:0, y: @backgroundSprite.height - @damageIcon.height}
        @.addChild @healthIcon
        @.addChild @damageIcon

      @width = CARD_SIZE.width
      @height = CARD_SIZE.height
      @.hitArea = new PIXI.Rectangle(0, 0, @width, @height)
      @.interactive = true

    setHealth: (health) -> @healthIcon.setHealth(health) if @healthIcon?
    setDamage: (damage) -> @damageIcon.setDamage(damage) if @damageIcon?
    setEnergy: (energy) -> @energyIcon.setEnergy(energy) if @energyIcon?
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
      if cardClass.playAbility? and cardClass.playAbility.text?
        text = @_buildAbilityText cardClass.playAbility.text, cardClass.playAbility.data
        text.position = {x:0, y: count * text.height}
        count++
        parent.addChild text

      for ability in cardClass.passiveAbilities
        text = @_buildAbilityText ability.text, ability.data
        text.position = {x: 0, y: count * text.height}
        count++
        parent.addChild text
      # TODO: Figure out how to display 'traits' such as rush
      return parent

    _buildAbilityText: (abilityText, abilityData) ->
      chunks = abilityText.split ' '
      string = ""
      for chunk in chunks
        # Extract a property from the metadata of the ability
        if /^<\w+>$/.test(chunk)
          prop = chunk.replace /[<>]/g, ''
          chunk = abilityData[prop]
          if not chunk?
            chunk = "[UNKNOWN: #{prop}]"
        string += (chunk + ' ')
      return new PIXI.Text string, styles.CARD_DESCRIPTION
