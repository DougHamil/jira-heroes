// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jquery', 'jiraheroes', 'gui', 'engine', 'pixi'], function($, JH, GUI, engine) {
    var CreateDeck;
    return CreateDeck = (function(_super) {
      __extends(CreateDeck, _super);

      function CreateDeck(manager, myStage) {
        var btn, hero, heroBtn, x, _i, _j, _len, _len1, _ref, _ref1,
          _this = this;
        this.manager = manager;
        this.myStage = myStage;
        CreateDeck.__super__.constructor.apply(this, arguments);
        this.heading = new PIXI.Text('Create A Deck', GUI.STYLES.HEADING);
        this.backBtn = new GUI.TextButton('Back');
        this.createBtn = new GUI.TextButton('Create');
        this.heroButtons = [];
        x = 100;
        _ref = JH.heroes;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          hero = _ref[_i];
          btn = new GUI.HeroButton(hero);
          btn.hero = hero;
          this.heroButtons.push(btn);
          btn.onClick(function(b) {
            return _this.setSelectedHero(b);
          });
          btn.position = {
            x: x,
            y: 100
          };
          x += btn.width + 100;
        }
        this.backBtn.position = {
          x: 20,
          y: engine.HEIGHT - this.backBtn.height - 20
        };
        this.backBtn.onClick(function() {
          return _this.manager.activateView('Decks');
        });
        this.createBtn.position = {
          x: 20,
          y: engine.HEIGHT - this.createBtn.height - 100
        };
        this.createBtn.onClick(function() {
          return _this.createDeck();
        });
        this.addChild(this.heading);
        this.addChild(this.backBtn);
        this.addChild(this.createBtn);
        _ref1 = this.heroButtons;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          heroBtn = _ref1[_j];
          this.addChild(heroBtn);
        }
      }

      CreateDeck.prototype.setSelectedHero = function(heroBtn) {
        var otherBtn, _i, _len, _ref;
        _ref = this.heroButtons;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          otherBtn = _ref[_i];
          otherBtn.setHighlight(false);
        }
        heroBtn.setHighlight(true);
        this.selectedHero = heroBtn.hero;
        return console.log(this.selectedHero);
      };

      CreateDeck.prototype.createDeck = function() {
        return this.createBtn.disable();
      };

      CreateDeck.prototype.activate = function() {
        this.setSelectedHero(this.heroButtons[0]);
        return this.myStage.addChild(this);
      };

      CreateDeck.prototype.deactivate = function() {
        return this.myStage.removeChild(this);
      };

      return CreateDeck;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
