class AIFactory
  @getAI: (type) ->
    clazz = require('./'+type)
    return new clazz()

module.exports = AIFactory
