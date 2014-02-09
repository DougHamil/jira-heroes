define ['gfx/icon', 'gfx/styles', 'util', 'pixi', 'tween'], (Icon, STYLES, Util) ->
  ICON_TEXTURE = '/media/images/icons/health.png'

  class HealthIcon extends Icon
    constructor: (health, @default) ->
      super(health.toString(), ICON_TEXTURE)
      @setHealth(health)

    setHealth:(health) ->
      @health = health
      @setText(health.toString())
      if health > @default
        @setStyle STYLES.ICON_TEXT_GOOD
      else if health < @default
        @setStyle STYLES.ICON_TEXT_BAD
      else
        @setStyle STYLES.ICON_TEXT_NORMAL
