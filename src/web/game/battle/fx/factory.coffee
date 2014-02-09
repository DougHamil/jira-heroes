define [
  'battle/fx/attack',
  'battle/fx/cast',
  'battle/fx/binary',
  'battle/fx/heal_shout',
  ], (
  Attack,
  Cast,
  Binary,
  HealShout
  ) ->
  FX_CLASSES =
    'cast':Cast
    'attack':Attack
    'binary':Binary
    'heal_shout':HealShout
  class FxFactory
    @create: (type, cons...) ->
      return new FX_CLASSES[type](cons...)

