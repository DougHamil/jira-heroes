mongoose = require 'mongoose'
Schema = mongoose.Schema

schema = new Schema
  user: {type:String, default:null}
  name: {type:String, default:"Deck"}
  hero: {type:Schema.Types.Mixed}
  cards: [{type:String}]

Deck = mongoose.model 'Deck', schema

module.exports = Deck
