mongoose = require 'mongoose'
Schema   = mongoose.Schema
ObjectId = Schema.ObjectId
fs = require 'fs'
path = require 'path'

_schema = new Schema
  name:{type:String}
  displayName:{type:String}
  media:
    icon: {type:String}

_model = mongoose.model('HeroClass', _schema)

appDir = path.join(process.cwd(), 'data/heroes')
for file in fs.readdirSync appDir
  if file.indexOf('.swp') != -1
    continue
  else
    console.log "Building hero #{file}"
    data = JSON.parse(fs.readFileSync(path.join(appDir, file), 'utf8'))
    _model.findOneAndUpdate {name:data.name}, data, {upsert:true}, (err)->
      if err?
        console.log "Error upserting hero: #{err}"

_get = (id, cb) ->
  _model.findOne {_id:id}, cb

_fromName = (name, cb) ->
  _model.findOne {name:name}, cb

module.exports =
  schema:_schema
  model:_model
  fromName: _fromName
  get:_get
