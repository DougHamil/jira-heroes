mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
fs = require 'fs'
path = require 'path'

schema = new Schema
  name:{type:String}
  displayName:{type:String}
  media:
    icon: {type:String}

HeroClass = mongoose.model('HeroClass', schema)

appDir = path.dirname process.mainModule.filename
appDir = path.join(appDir, 'data/heroes')
for file in fs.readdirSync appDir
  if file.indexOf('.swp') != -1
    continue
  else
    console.log "Building hero #{file}"
    data = JSON.parse(fs.readFileSync(path.join(appDir, file), 'utf8'))
    HeroClass.findOneAndUpdate {name:data.name}, data, {upsert:true}, (err)->
      if err?
        console.log "Error upserting hero: #{err}"

module.exports = HeroClass
