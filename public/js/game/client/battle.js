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
        this.socket.on('phase', function(oldPhase, newPhase) {
          return _this.onPhaseChanged(oldPhase, newPhase);
        });
      }

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

      Battle.prototype.emitReadyEvent = function(cb) {
        return this.socket.emit('ready', cb);
      };

      return Battle;

    })(EventEmitter);
  });

}).call(this);