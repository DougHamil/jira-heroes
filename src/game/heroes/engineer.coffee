Hero = require '../hero'

class Engineer extends Hero
  initState: ->
    state = super()
    state.damage = 'A million'
    return state

module.exports = Engineer
