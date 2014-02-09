define [
  'battle/fx/attack',
  'battle/fx/cast',
  'battle/fx/zap',
  'battle/fx/binary',
  ], (
  Attack,
  Cast,
  Zap,
  Binary
  ) ->
  FX_CLASSES =
    'zap':Zap
    'cast':Cast
    'attack':Attack
    'binary':Binary
  class FxFactory
    @create: (type, cons...) ->
      return new FX_CLASSES[type](cons...)

