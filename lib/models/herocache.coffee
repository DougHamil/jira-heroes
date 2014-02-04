async = require 'async'
Heroes = require '../../lib/models/hero'

###
# Simple cache for Hero data
###
class HeroCache
  @heroes: {}
  @allLoaded: false
  @loadAll: (cb) ->
    Heroes.getAll (err, heroes) =>
      if err?
        cb err
      else
        for hero in heroes
          @heroes[hero._id] = hero
        cb null
  @getAll: (cb) ->
    if @allLoaded
      cb null, (hero for id, hero of @heroes)
    else
      Heroes.getAll (err, heroes) =>
        if err?
          cb err
        else
          for hero in heroes
            @heroes[hero._id] = hero
          @allLoaded = true # Mark that we have loaded all heroes so subsequent requests won't hit database
          cb null, heroes

  @get: (heroId, cb) ->
    if @heroes[heroId]?
      cb null, @heroes[heroId]
    else
      Heroes.get heroId, (err, hero) =>
        if err?
          cb err
        else
          @heroes[heroId] = hero
          cb null, hero


module.exports = HeroCache
