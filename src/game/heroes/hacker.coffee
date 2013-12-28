Hero = require '../hero'

class Hacker extends Hero
  initState: ->
    state = super()
    state.damage = 'A billion'
    return state

module.exports = Hacker
