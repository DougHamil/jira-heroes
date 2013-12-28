mongoose = require 'mongoose'
fs = require 'fs'
path = require 'path'

schema = new mongoose.Schema
  name:{type:String}
  health:{type:Number}
  damage:{type:Number}
  traits:[{type:String}]
  flags:[{type:String}]
  media:
    icon: {type:String}
    audio:
      attack:{type:String}
      hurt:{type:String}
      death:{type:String}

Card = mongoose.model 'Card', schema

dir = process.cwd()
dir = path.join dir, 'data/cards'
for file in fs.readdirSync dir
  if file.indexOf('.swp') != -1
    continue
  else
    process.stdout.write "Building card #{file}..."
    data = JSON.parse(fs.readFileSync(path.join(dir, file), 'utf8'))
    Card.findOneAndUpdate {name:data.name}, data, {upsert:true}, (err) ->
      if err?
        console.log "Error upserting card: #{err}"
      else
        console.log "Done!"

module.exports = Card
