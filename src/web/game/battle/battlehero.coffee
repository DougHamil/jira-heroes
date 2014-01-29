define ['eventemitter', 'battle/animation', 'gui', 'engine', 'util', 'pixi'], (EventEmitter, Animation, GUI, engine, Util) ->
  class BattleHero extends EventEmitter
    constructor: (@hero, @heroClass, @interactive) ->
      super
      @token = new GUI.HeroToken @hero, @heroClass

    containsPoint: (point) -> return @token.contains(point)
    getId: -> return @hero.userId
    getTokenSprite: -> return @token
