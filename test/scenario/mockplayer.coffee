class MockPlayer
  constructor: (@_id, opts) ->
    if opts?
      for field, val of opts
        @[field] = val
    else
      @energy = 0
      @deck =
        hero:
          _id:@_id
          class: 'hacker'
          health: 30
          maxHealth: 30
          damage: 0
        cards: []

module.exports = MockPlayer
