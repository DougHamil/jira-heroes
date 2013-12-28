mongoose = require 'mongoose'

schema = new mongoose.Schema
  players:[{type:mongoose.Schema.Types.Mixed}]     # Player ids and snapshots of each deck
  phase:{type:String}

Battle = mongoose.model 'Battle', schema
module.exports = Battle
