define ['gfx/icon', 'gfx/styles', 'util', 'pixi', 'tween'], (Icon, STYLES, Util) ->
  ICON_TEXTURE = '/media/images/icons/damage.png'

  class DamageIcon extends Icon
    constructor: (damage, @default) ->
      super(damage.toString(), ICON_TEXTURE)
      @setDamage(damage)

    setDamage:(damage) ->
      @setText(damage.toString())
      if damage > @default
        @setStyle STYLES.ICON_TEXT_GOOD
      else if damage < @default
        @setStyle STYLES.ICON_TEXT_BAD
      else
        @setStyle STYLES.ICON_TEXT_NORMAL
