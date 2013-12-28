HeroClassModel = require '../lib/models/hero.class'

class HeroClassCache
  @heroClasses: {}
  @load: (heroClassId, cb) ->
    if @heroClasses[heroClassId]?
      cb null, @heroClasses[heroClassId]
    else
      HeroClassModel.findOne {_id:heroClassId}, (err, heroClass) =>
        if err?
          cb err
        else
          @heroClasses[heroClass._id] = heroClass
          cb null, heroClass

module.exports = HeroClassCache
