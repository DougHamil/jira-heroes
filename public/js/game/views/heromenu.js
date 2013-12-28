// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['jiraheroes', 'engine', 'gui', 'pixi'], function(JH, engine, GUI) {
    var BACKGROUND_TEXTURE, HeroMenu;
    BACKGROUND_TEXTURE = PIXI.Texture.fromImage('/media/images/backgrounds/heromenu.png');
    return HeroMenu = (function(_super) {
      __extends(HeroMenu, _super);

      function HeroMenu(manager, stage) {
        var _this = this;
        this.manager = manager;
        HeroMenu.__super__.constructor.apply(this, arguments);
        this.myStage = stage;
        this.bgSprite = new PIXI.Sprite(BACKGROUND_TEXTURE);
        this.menuText = new PIXI.Text('Select a Hero', GUI.STYLES.HEADING);
        this.newBtn = new GUI.TextButton('New');
        this.newBtn.position = {
          x: engine.WIDTH / 2,
          y: (engine.HEIGHT / 2) + 2 * this.newBtn.height
        };
        this.newBtn.onClick(function() {
          return _this.manager.activateView('CreateHeroMenu');
        });
        this.addChild(this.menuText);
        this.addChild(this.newBtn);
      }

      HeroMenu.prototype.deactivate = function() {
        var btn, _i, _len, _ref, _results;
        this.myStage.removeChild(this);
        _ref = this.heroButtons;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          btn = _ref[_i];
          _results.push(this.removeChild(btn));
        }
        return _results;
      };

      HeroMenu.prototype.onHeroClicked = function(hero) {
        var _this = this;
        if (hero.campaign != null) {
          return JH.GetCampaign(hero.campaign, function(campaign) {
            return _this.manager.activateView('Campaign', hero, campaign);
          });
        } else {
          return this.manager.activateView('CampaignMenu', hero);
        }
      };

      HeroMenu.prototype.activate = function() {
        var _this = this;
        this.myStage.addChild(this);
        return JH.GetHeroes(function(heroes) {
          var btn, hero, heroButtonHandler, x, y, _i, _len, _results;
          x = 50;
          y = 100;
          _this.heroButtons = [];
          heroButtonHandler = function(hero) {
            return function() {
              return _this.onHeroClicked(hero);
            };
          };
          _results = [];
          for (_i = 0, _len = heroes.length; _i < _len; _i++) {
            hero = heroes[_i];
            btn = new GUI.HeroButton(hero);
            btn.position.x = x;
            btn.position.y = y;
            x = x + 350;
            _this.addChild(btn);
            btn.onClick(heroButtonHandler(hero));
            _results.push(_this.heroButtons.push(btn));
          }
          return _results;
        });
      };

      return HeroMenu;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
