Hero = require '../hero'

class Tester extends Hero
  initState: ->
    state = super()
    state.damage = 'A little'
    return state

module.exports = Tester
