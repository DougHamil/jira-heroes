// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['gfx/styles', 'gfx/deckcardlistentry', 'util', 'engine', 'pixi', 'tween'], function(STYLES, DeckCardListEntry, Util, engine) {
    var DeckCardList, ENTRY_HEIGHT, ENTRY_WIDTH, HEIGHT, PADDING, WIDTH;
    HEIGHT = engine.HEIGHT - 100;
    WIDTH = engine.WIDTH / 4;
    PADDING = 5;
    ENTRY_HEIGHT = Math.floor(HEIGHT / 30);
    ENTRY_WIDTH = WIDTH - PADDING;
    /*
    # Lists all of the cards within a deck in compact form for the Deck Editor
    */

    return DeckCardList = (function(_super) {
      __extends(DeckCardList, _super);

      function DeckCardList(deck, cardClasses) {
        this.deck = deck;
        this.cardClasses = cardClasses;
        DeckCardList.__super__.constructor.apply(this, arguments);
        this.bg = new PIXI.Graphics();
        this.bg.width = WIDTH;
        this.bg.height = HEIGHT;
        this.bg.beginFill(STYLES.BUTTON_COLOR);
        this.bg.drawRect(0, 0, this.bg.width, this.bg.height);
        this.width = this.bg.width;
        this.height = this.bg.height;
        this.addChild(this.bg);
        this.update();
      }

      DeckCardList.prototype.update = function() {
        var card, cardId, entry, _i, _len, _ref, _ref1;
        if (this.entries != null) {
          _ref = this.entries;
          for (cardId in _ref) {
            entry = _ref[cardId];
            this.removeChild(entry);
          }
        }
        this.entries = {};
        this.cardCounts = {};
        _ref1 = this.deck.cards;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          card = _ref1[_i];
          if (this.cardCounts[card] == null) {
            this.cardCounts[card] = 1;
          } else {
            this.cardCounts[card]++;
          }
          if (this.entries[card] != null) {
            this.entries[card].setCount(this.cardCounts[card]);
          } else {
            this.entries[card] = new DeckCardListEntry(ENTRY_WIDTH, ENTRY_HEIGHT, this.cardClasses[card]);
            this.addChild(this.entries[card]);
          }
        }
        return this.positionEntries();
      };

      DeckCardList.prototype.positionEntries = function() {
        var cardId, entry, orderedEntries, y, _i, _len, _ref, _results;
        orderedEntries = [];
        _ref = this.entries;
        for (cardId in _ref) {
          entry = _ref[cardId];
          orderedEntries.push({
            entry: entry,
            energy: this.cardClasses[cardId].energy
          });
        }
        orderedEntries.sort(function(a, b) {
          return a.energy - b.energy;
        });
        y = 0;
        _results = [];
        for (_i = 0, _len = orderedEntries.length; _i < _len; _i++) {
          entry = orderedEntries[_i];
          entry = entry.entry;
          entry.position = {
            x: 0,
            y: y
          };
          _results.push(y += ENTRY_HEIGHT);
        }
        return _results;
      };

      return DeckCardList;

    })(PIXI.DisplayObjectContainer);
  });

}).call(this);
