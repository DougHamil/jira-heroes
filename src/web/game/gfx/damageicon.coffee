define ['gfx/icon', 'gfx/styles', 'util', 'pixi', 'tween'], (Icon, STYLES, Util) ->
  ICON_TEXTURE = '/media/images/icons/damage.png'

  class DamageIcon extends Icon
    constructor: (damage) ->
      super(damage.toString(), ICON_TEXTURE)

    setDamage:(damage) ->
      @setText(damage.toString())
