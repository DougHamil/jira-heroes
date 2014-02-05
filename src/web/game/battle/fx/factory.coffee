define [
  'battle/fx/attack',
  'battle/fx/zap' ], (
  Attack,
  Zap) ->
  FX_CLASSES =
    'zap':Zap
    'attack':Attack
  class FxFactory
    @create: (type, cons...) ->
      return new FX_CLASSES[type](cons...)

