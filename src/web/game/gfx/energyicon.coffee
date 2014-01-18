define ['gfx/icon', 'gfx/styles', 'util', 'pixi', 'tween'], (Icon, STYLES, Util) ->
  ICON_TEXTURE = '/media/images/icons/energy.png'

  class EnergyIcon extends Icon
    constructor: (energy) ->
      super(energy.toString(), ICON_TEXTURE)

    setEnergy:(energy) ->
      @setText(energy.toString())
