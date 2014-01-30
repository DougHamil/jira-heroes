define [
  'battle/fx/attack',
  'battle/fx/zap' ], (
  Attack,
  Zap) ->
  FX_CLASSES =
    'zap':Zap
    'attack':Attack
  class FxFactory
    @create: (type, fxdata) ->
      return new FX_CLASSES[type](fxdata)

