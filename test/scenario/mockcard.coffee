class MockCard
  constructor:(@_id, opts) ->
    if opts?
      for field, val of opts
        @[field] = val
    else
      @health = 0
      @maxHealth = 0
      @damage = 0
      @position = 'hand'
      @traits = []
      @status = []
      @handler =
        unregisterPassiveAbilities: ->

module.exports = MockCard
