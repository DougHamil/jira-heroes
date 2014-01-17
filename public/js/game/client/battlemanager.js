// Generated by CoffeeScript 1.6.3
(function() {
  var __hasProp = {}.hasOwnProperty,
    __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

  define(['util', 'engine', 'client/battle', 'eventemitter'], function(Util, engine, Battle, EventEmitter) {
    var BattleManager, POLL_DELAY;
    POLL_DELAY = 3000;
    return BattleManager = (function(_super) {
      __extends(BattleManager, _super);

      function BattleManager(user, battleId) {
        var pollStatus,
          _this = this;
        this.user = user;
        this.battleId = battleId;
        BattleManager.__super__.constructor.apply(this, arguments);
        this.battleReady = false;
        this.socket = io.connect();
        this.socket.on('connected', function() {
          return _this.onConnected();
        });
        this.socket.on('disconnect', function() {
          return _this.onDisconnected();
        });
        pollStatus = function() {
          return _this.pollBattleStatus();
        };
        this.pollTimeout = setTimeout(pollStatus, POLL_DELAY);
        this.pollBattleStatus();
      }

      BattleManager.prototype.pollBattleStatus = function() {
        var _this = this;
        return this.socket.emit('battle-status', this.battleId, function(status) {
          var pollStatus;
          if ((status == null) && !_this.battleReady) {
            _this.battleReady = true;
            _this.emit('battle-ready');
            return clearTimeout(_this.pollTimeout);
          } else {
            _this.emit('battle-status', status);
            pollStatus = function() {
              return _this.pollBattleStatus();
            };
            return _this.pollTimeout = setTimeout(pollStatus, POLL_DELAY);
          }
        });
      };

      BattleManager.prototype.join = function() {
        var _this = this;
        return this.socket.emit('join', this.battleId, function(err, battleModel) {
          if (err == null) {
            _this.battle = new Battle(_this.user._id, battleModel, _this.socket);
            return _this.emit('joined', _this.battle);
          }
        });
      };

      BattleManager.prototype.onConnected = function() {
        return this.emit('connected');
      };

      BattleManager.prototype.onDisconnected = function() {
        return this.emit('disconnected');
      };

      BattleManager.prototype.disconnect = function() {
        return this.socket.disconnect();
      };

      BattleManager.prototype.getBattle = function() {
        return this.battle;
      };

      return BattleManager;

    })(EventEmitter);
  });

}).call(this);
