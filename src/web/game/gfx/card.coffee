define ['gfx/damageicon', 'gfx/healthicon','gfx/energyicon','gfx/styles', 'util', 'pixi', 'tween'], (DamageIcon, HealthIcon, EnergyIcon, styles, Util) ->
  CARD_SIZE =
    width: 150
    height: 225
  IMAGE_POS =
    x: 3
    y: 3
  IMAGE_SIZE =
    width: 498 * (CARD_SIZE.width / 512)
    height: 498 * (CARD_SIZE.height / 768)
  IMAGE_MASK =
    width: IMAGE_SIZE.width
    height: 336 * (CARD_SIZE.height / 768)
  IMAGE_PATH = '/media/images/cards/'
  BACKGROUND_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'background.png'
  MISSING_TEXTURE = PIXI.Texture.fromImage IMAGE_PATH + 'missing.png'

  ###
  # Draws everything for a card, showing the image, damage, heatlh, status, etc.
  ###
  class Card extends PIXI.DisplayObjectContainer
    @Width: CARD_SIZE.width
    @Height: CARD_SIZE.height
    @FromClass: (cardClass) ->
      return new Card cardClass, cardClass.damage, cardClass.health, []
    constructor: (cardClass, damage, health, status) ->
      super()
      imageTexture = PIXI.Texture.fromImage IMAGE_PATH + cardClass.media.image
      @backgroundSprite = new PIXI.Sprite BACKGROUND_TEXTURE
      @backgroundSprite.width = CARD_SIZE.width
      @backgroundSprite.height = CARD_SIZE.height
      @imageSprite = new PIXI.Sprite imageTexture
      @imageSprite.width = IMAGE_SIZE.width
      @imageSprite.height = IMAGE_SIZE.height
      @titleText = new PIXI.Text cardClass.displayName, styles.CARD_TITLE
      if @titleText.width >= @backgroundSprite.width - 20
        @titleText.width = @backgroundSprite.width - 20
      @energyIcon = new EnergyIcon cardClass.energy
      @description = @buildAbilityText cardClass
      @description.position = {x:5, y: @backgroundSprite.height / 2 + 25}
      @titleText.anchor = {x: 0.5, y:0.5}
      @titleText.position = {x:@backgroundSprite.width / 2, y: @backgroundSprite.height/2+4}
      @energyIcon.position = {x:0, y:0}
      @imageSprite.position = {x: IMAGE_POS.x, y: IMAGE_POS.y}

      @.addChild @imageSprite
      @.addChild @backgroundSprite
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
      if 'taunt' in cardClass.traits
        text = new PIXI.Text "Taunt", styles.CARD_DESCRIPTION
        text.position = {x:0, y: count * text.height}
        count++
        parent.addChild text
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

    getCenterPosition: ->
      return {x:@.position.x + @width/2, y:@.position.y + @height/2}
