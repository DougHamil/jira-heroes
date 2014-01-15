// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['gfx/styles', 'util', 'engine', 'pixi', 'tween'], function(STYLES, Util, engine) {
    var CARD_HEIGHT, CARD_WIDTH, HIGHLIGHT_WIDTH, HeroButton;
    HIGHLIGHT_WIDTH = 10;
    CARD_HEIGHT = 300;
    CARD_WIDTH = 200;
    return HeroButton = (function(_super) {
      __extends(HeroButton, _super);

      function HeroButton(hero) {
        var texture,
          _this = this;
        HeroButton.__super__.constructor.apply(this, arguments);
        if (hero.media.icon != null) {
          texture = PIXI.Texture.fromImage(hero.media.icon);
          this.icon = new PIXI.Sprite(texture);
          this.icon.anchor = {
            x: 0.5,
            y: 0.5
          };
          this.icon.position = {
            x: 100,
            y: 150
          };
        }
        this.name = new PIXI.Text(hero.displayName, STYLES.TEXT);
        this.bg = new PIXI.Graphics();
        this.bg.width = CARD_WIDTH;
        this.bg.height = CARD_HEIGHT;
        this.bg.beginFill(STYLES.BUTTON_COLOR);
        this.bg.drawRect(0, 0, this.bg.width, this.bg.height);
        this.highlight = new PIXI.Graphics();
        this.highlight.beginFill(STYLES.HIGHLIGHT_COLOR);
        this.highlight.drawRect(-HIGHLIGHT_WIDTH, -HIGHLIGHT_WIDTH, this.bg.width + HIGHLIGHT_WIDTH * 2, this.bg.height + HIGHLIGHT_WIDTH * 2);
        this.highlight.visible = false;
        this.name.anchor = {
          x: 0.5,
          y: 1.0
        };
        this.name.position = {
          x: 100,
          y: 300 - (this.name.height + 20)
        };
        this.from = {
          x: 0,
          y: 0
        };
        this.to = {
          x: 0,
          y: 10
        };
        this.cont = new PIXI.DisplayObjectContainer();
        this.cont.interactive = true;
        this.cont.hitArea = new PIXI.Rectangle(0, 0, this.bg.width, this.bg.height);
        this.cont.addChild(this.highlight);
        this.cont.addChild(this.bg);
        if (this.icon) {
          this.cont.addChild(this.icon);
        }
        this.cont.addChild(this.name);
        this.tweens = {
          selected: function() {
            return Util.spriteTween(_this.cont, _this.from, _this.to, 500).repeat(Infinity).yoyo(true).easing(TWEEN.Easing.Sinusoidal.InOut);
          }
        };
        this.addChild(this.cont);
        this.interactive = true;
        this.mouseover = function() {
          return _this.animate('selected');
        };
        this.mouseout = function() {
          return _this.animate('none');
        };
        this.width = this.bg.width;
        this.height = this.bg.height;
      }

      HeroButton.prototype.setHighlight = function(enabled) {
        return this.highlight.visible = enabled;
      };

      HeroButton.prototype.onClick = function(callback) {
        var _this = this;
        return this.click = function() {
          return callback(_this);
        };
      };

      HeroButton.prototype.animate = function(animation) {
        if ((this.lastAnim != null) && this.lastAnim === animation) {
          return;
        }
        this.lastAnim = animation;
        if (animation === 'none') {
          if (this.activeTween != null) {
            this.activeTween.repeat(0);
          }
          this.activeTween = null;
          return;
        }
        this.activeTween = this.tweens[animation]();
        return this.activeTween.repeat(Infinity).start();
      };

      return HeroButton;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
