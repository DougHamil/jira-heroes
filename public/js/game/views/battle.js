// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'jiraheroes', 'gui', 'client/battlemanager', 'engine', 'pixi'], function($, JH, GUI, BattleManager, engine) {
    /*
    # This view displays the actual battle part of the game to the player
    */

    var Battle;
    return Battle = (function(_super) {
      __extends(Battle, _super);

      function Battle(manager, myStage) {
        this.manager = manager;
        this.myStage = myStage;
        Battle.__super__.constructor.apply(this, arguments);
      }

      Battle.prototype.activate = function(battle) {
        var _this = this;
        this.battle = battle;
        this.myStage.addChild(this);
        this.battleManager = new BattleManager(this.battle);
        return this.battleManager.on('connected', function() {
          return console.log("IM CONNECTED");
        });
      };

      Battle.deactivate = function() {
        return this.myStage.removeChild(this);
      };

      return Battle;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
