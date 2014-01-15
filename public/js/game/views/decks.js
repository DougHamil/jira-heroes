// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], function($, JH, GUI, engine) {
    var Decks;
    return Decks = (function(_super) {
      __extends(Decks, _super);

      function Decks(manager, myStage) {
        var _this = this;
        this.manager = manager;
        this.myStage = myStage;
        Decks.__super__.constructor.apply(this, arguments);
        this.heading = new PIXI.Text('Decks', GUI.STYLES.HEADING);
        this.backBtn = new GUI.TextButton('Back');
        this.createDeckBtn = new GUI.TextButton('Create Deck');
        this.backBtn.position = {
          x: 20,
          y: engine.HEIGHT - this.backBtn.height - 20
        };
        this.backBtn.onClick(function() {
          return _this.manager.activateView('MainMenu');
        });
        this.createDeckBtn.position = {
          x: 20,
          y: engine.HEIGHT - this.createDeckBtn.height - 100
        };
        this.createDeckBtn.onClick(function() {
          return _this.manager.activateView('CreateDeck');
        });
        this.addChild(this.heading);
        this.addChild(this.backBtn);
        this.addChild(this.createDeckBtn);
      }

      Decks.prototype.activate = function() {
        var activate,
          _this = this;
        activate = function(decks) {
          console.log(decks);
          return _this.myStage.addChild(_this);
        };
        return JH.GetAllDecks(function(decks) {
          return activate(decks);
        });
      };

      Decks.prototype.deactivate = function() {
        return this.myStage.removeChild(this);
      };

      return Decks;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
