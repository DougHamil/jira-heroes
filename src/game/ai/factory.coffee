class AIFactory
  @cache: {}
  @getAI: (type) ->
    if not @cache[type]?
      @cache[type] = require('./'+type)
    clazz = @cache[type]
    return new clazz()

module.exports = AIFactory
