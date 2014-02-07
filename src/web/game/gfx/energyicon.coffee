define ['gfx/icon', 'gfx/styles', 'util', 'pixi', 'tween'], (Icon, STYLES, Util) ->
  ICON_TEXTURE = '/media/images/icons/energy.png'

  class EnergyIcon extends Icon
    constructor: (energy, @default) ->
      super(energy.toString(), ICON_TEXTURE)
      @setEnergy(energy)

    setEnergy:(energy) ->
      @setText(energy.toString())
      if energy > @default
        @setStyle STYLES.ICON_TEXT_BAD
      else if energy < @default
        @setStyle STYLES.ICON_TEXT_GOOD
      else
        @setStyle STYLES.ICON_TEXT_NORMAL
