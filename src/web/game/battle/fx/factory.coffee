define [
  'battle/fx/attack',
  'battle/fx/cast',
  'battle/fx/zap' ], (
  Attack,
  Cast,
  Zap) ->
  FX_CLASSES =
    'zap':Zap
    'cast':Cast
    'attack':Attack
  class FxFactory
    @create: (type, cons...) ->
      return new FX_CLASSES[type](cons...)

