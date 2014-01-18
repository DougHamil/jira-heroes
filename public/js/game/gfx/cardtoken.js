// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['gfx/damageicon', 'gfx/healthicon', 'gfx/styles', 'util', 'pixi', 'tween'], function(DamageIcon, HealthIcon, STYLES, Util) {
    var CLIP_TEXTURE, CardToken, FRAME_TEXTURE, IMAGE_PATH, MISSING_TEXTURE, TAUNT_FRAME_TEXTURE, TOKEN_HEIGHT, TOKEN_WIDTH;
    TOKEN_WIDTH = 128;
    TOKEN_HEIGHT = 128;
    IMAGE_PATH = '/media/images/cards/';
    CLIP_TEXTURE = PIXI.Texture.fromImage(IMAGE_PATH + 'token_clip.png');
    FRAME_TEXTURE = PIXI.Texture.fromImage(IMAGE_PATH + 'token_frame.png');
    TAUNT_FRAME_TEXTURE = PIXI.Texture.fromImage(IMAGE_PATH + 'token_frame_taunt.png');
    MISSING_TEXTURE = PIXI.Texture.fromImage(IMAGE_PATH + 'missing.png');
    /*
    # Represents a card on the field, shown as the card's image with health and damage icons. Minimalized version of the source card.
    */

    return CardToken = (function(_super) {
      __extends(CardToken, _super);

      function CardToken(card, cardClass) {
        var imageTexture;
        CardToken.__super__.constructor.apply(this, arguments);
        imageTexture = PIXI.Texture.fromImage(IMAGE_PATH + cardClass.media.image);
        if (!imageTexture.hasLoaded) {
          imageTexture = MISSING_TEXTURE;
        }
        this.width = TOKEN_WIDTH;
        this.height = TOKEN_HEIGHT;
        this.imageSprite = new PIXI.Sprite(imageTexture);
        this.imageSprite.width = TOKEN_WIDTH;
        this.imageSprite.height = TOKEN_HEIGHT;
        this.imageSprite.mask = this.createImageMask();
        this.frameSprite = new PIXI.Sprite(FRAME_TEXTURE);
        this.frameSprite.width = TOKEN_WIDTH;
        this.frameSprite.height = TOKEN_HEIGHT;
        this.tauntFrameSprite = new PIXI.Sprite(TAUNT_FRAME_TEXTURE);
        this.tauntFrameSprite.width = TOKEN_WIDTH;
        this.tauntFrameSprite.height = TOKEN_HEIGHT;
        this.damageIcon = new DamageIcon(card.damage);
        this.healthIcon = new HealthIcon(card.health);
        this.damageIcon.anchor = {
          x: 0.5,
          y: 0.5
        };
        this.healthIcon.anchor = {
          x: 0.5,
          y: 0.5
        };
        this.damageIcon.position = {
          x: -this.damageIcon.width / 2,
          y: this.height - this.damageIcon.height / 2
        };
        this.healthIcon.position = {
          x: this.width - this.healthIcon.width / 2,
          y: this.height - this.healthIcon.height / 2
        };
        this.addChild(this.imageSprite);
        this.addChild(this.frameSprite);
        this.addChild(this.tauntFrameSprite);
        this.addChild(this.healthIcon);
        this.addChild(this.damageIcon);
        this.setTaunt((__indexOf.call(card.status, 'taunt') >= 0));
      }

      CardToken.prototype.setHealth = function(health) {
        return this.healthIcon.setHealth(health);
      };

      CardToken.prototype.setDamage = function(damage) {
        return this.damageIcon.setDamage(damage);
      };

      CardToken.prototype.setTaunt = function(isTaunting) {
        this.tauntFrameSprite.visible = isTaunting;
        return this.frameSprite.visible = !isTaunting;
      };

      CardToken.prototype.onHoverStart = function(cb) {
        var _this = this;
        return this.mouseover = function() {
          return cb(_this);
        };
      };

      CardToken.prototype.onHoverEnd = function(cb) {
        var _this = this;
        return this.mouseout = function() {
          return cb(_this);
        };
      };

      CardToken.prototype.onMouseUp = function(cb) {
        var _this = this;
        return this.mouseup = function() {
          return cb(_this);
        };
      };

      CardToken.prototype.onMouseDown = function(cb) {
        var _this = this;
        return this.mousedown = function() {
          return cb(_this);
        };
      };

      CardToken.prototype.createImageMask = function() {
        var mask;
        mask = new PIXI.Graphics();
        mask.beginFill();
        mask.drawCircle(0, 0, TOKEN_WIDTH / 2);
        mask.endFill();
        return mask;
      };

      return CardToken;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
