mongoose = require 'mongoose'
Schema = mongoose.Schema
ObjectId = Schema.ObjectId

schema = new Schema
  name: String
  email: String
  lastLogin: String
  lastLoginPoints: {type:Number, default:0}
  lastLoginIssueKeys: [String]
  decks: [{type:String}]
  points: {type:Number, default:0}

schema.methods.hasDeck = (deckId) ->
  return deckId in @decks

User = mongoose.model('User', schema)
module.exports = User
