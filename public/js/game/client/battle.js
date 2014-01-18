// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

  define(['util', 'engine', 'eventemitter', 'pixi'], function(Util, engine, EventEmitter) {
    /*
    # Handles changes to the battle's state
    */

    var Battle;
    return Battle = (function(_super) {
      __extends(Battle, _super);

      function Battle(userId, model, socket) {
        var _this = this;
        this.userId = userId;
        this.model = model;
        this.socket = socket;
        Battle.__super__.constructor.apply(this, arguments);
        this.socket.on('player-connected', function(userId) {
          return _this.onPlayerConnected(userId);
        });
        this.socket.on('player-disconnected', function(userId) {
          return _this.onPlayerDisconnected(userId);
        });
        this.socket.on('player-ready', function(userId) {
          return _this.onPlayerReadied(userId);
        });
        this.socket.on('your-turn', function(actions) {
          return _this.processAndEmit('your-turn', actions);
        });
        this.socket.on('opponent-turn', function(actions) {
          return _this.processAndEmit('opponent-turn', actions);
        });
        this.socket.on('phase', function(oldPhase, newPhase) {
          return _this.onPhaseChanged(oldPhase, newPhase);
        });
      }

      Battle.prototype.processAndEmit = function(event, actions) {
        var action, _i, _len;
        for (_i = 0, _len = actions.length; _i < _len; _i++) {
          action = actions[_i];
          this.process(action);
        }
        return this.emit(event, actions);
      };

      Battle.prototype.process = function(action) {
        console.log(action);
        switch (action.type) {
          case 'start-turn':
            return this.model.activePlayer = action.player;
          case 'draw-card':
            console.log(action);
            return this.getPlayer(action.player).hand.push(action.card);
          case 'max-energy':
            return this.getPlayer(action.player).maxEnergy += action.amount;
          case 'energy':
            return this.getPlayer(action.player).energy += action.amount;
        }
      };

      Battle.prototype.onPhaseChanged = function(oldPhase, newPhase) {
        this.model.state.phase = newPhase;
        return this.emit('phase', oldPhase, newPhase);
      };

      Battle.prototype.onPlayerReadied = function(userId) {
        this.model.readiedPlayers.push(userId);
        return this.emit('player-readied', userId);
      };

      Battle.prototype.onPlayerConnected = function(userId) {
        this.model.connectedPlayers.push(userId);
        return this.emit('player-connected', userId);
      };

      Battle.prototype.onPlayerDisconnected = function(userId) {
        this.model.connectedPlayers = this.model.connectedPlayers.filter(function(p) {
          return p !== userId;
        });
        return this.emit('player-disconnected', userId);
      };

      Battle.prototype.getPlayer = function(id) {
        var user, _i, _len, _ref;
        if (id === this.userId) {
          return this.model.you;
        } else {
          _ref = this.model.opponents;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            user = _ref[_i];
            if (user.userId === id) {
              return user;
            }
          }
          return null;
        }
      };

      Battle.prototype.getConnectedPlayers = function() {
        return this.model.connectedPlayers;
      };

      Battle.prototype.getPhase = function() {
        return this.model.state.phase;
      };

      Battle.prototype.isReadied = function() {
        var _ref;
        return _ref = this.userId, __indexOf.call(this.model.readiedPlayers, _ref) >= 0;
      };

      Battle.prototype.getCardsInHand = function() {
        return this.model.you.hand;
      };

      Battle.prototype.getCardsOnField = function() {
        return this.model.you.field;
      };

      Battle.prototype.getEnergy = function() {
        return this.model.you.energy;
      };

      Battle.prototype.getMaxEnergy = function() {
        return this.model.you.maxEnergy;
      };

      Battle.prototype.emitReadyEvent = function(cb) {
        return this.socket.emit('ready', cb);
      };

      Battle.prototype.emitPlayCardEvent = function(cardId, target, cb) {
        return this.socket.emit('play-card', cardId, target, cb);
      };

      return Battle;

    })(EventEmitter);
  });

}).call(this);
