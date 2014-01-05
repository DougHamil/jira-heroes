// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['gfx/styles', 'util', 'pixi', 'tween'], function(styles, Util) {
    var GLYPHS, GlyphText, STYLE;
    STYLE = styles.TEXT;
    GLYPHS = {
      'coin': '/media/images/icons/coin.png'
    };
    return GlyphText = (function(_super) {
      __extends(GlyphText, _super);

      function GlyphText(text) {
        var chunk, glyph, lastSprite, sprite, sprites, textChunks, texture, _i, _j, _len, _len1;
        GlyphText.__super__.constructor.call(this);
        textChunks = text.split(' ');
        sprites = [];
        this.width = 0;
        for (_i = 0, _len = textChunks.length; _i < _len; _i++) {
          chunk = textChunks[_i];
          sprite = null;
          if (/^<\w+>$/.test(chunk)) {
            glyph = chunk.replace(/[<>]/g, '');
            texture = PIXI.Texture.fromImage(GLYPHS[glyph]);
            sprite = new PIXI.Sprite(texture);
          } else {
            chunk += ' ';
            sprite = new PIXI.Text(chunk, STYLE);
          }
          if (sprites.length > 0) {
            lastSprite = sprites[sprites.length - 1];
            sprite.height = lastSprite.height;
            this.height = sprite.height;
            sprite.width = sprite.height;
            sprite.position = {
              x: lastSprite.position.x + lastSprite.width,
              y: 0
            };
          }
          sprites.push(sprite);
        }
        for (_j = 0, _len1 = sprites.length; _j < _len1; _j++) {
          sprite = sprites[_j];
          this.width += sprite.width;
          this.addChild(sprite);
        }
      }

      return GlyphText;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
