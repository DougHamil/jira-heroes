CONFIG = require './config'
mongoose       = require 'mongoose'
express        = require 'express'
jiraapi        = require './jira/api'
UserController = require './controllers/user'
ViewsController = require './controllers/views'
TestController = require './controllers/test'
gameServer     = require './game/server'

secret       = 'JIRA_HERO_SECRET'
sessionStore = new express.session.MemoryStore()
cookieParser = express.cookieParser(secret)

mongoose.connect('mongodb://localhost:27017/test')

db = mongoose.connection
db.on('error', console.error.bind(console, 'connection error:'))
db.once 'open', ->
  # Init web server
  app = express()
  app.use express.bodyParser()
  app.use express.cookieParser()
  app.use express.session({store:sessionStore, secret: secret, key:'connect.sid'})
  app.use express.static('public')
  app.set 'views', __dirname + '/views'
  app.set 'view engine', 'jade'
#
# Init controllers
  UserController.init app
  ViewsController.init app
  # TEST ONLY
  TestController.init app

  app.all '/secure/*', (req, res, next) ->
    if not req.session.user?
      if CONFIG.DEV_USERNAME? and CONFIG.DEV_PASSWORD
        UserController.loginUser CONFIG.DEV_USERNAME, CONFIG.DEV_PASSWORD, (err, user) ->
          if not err?
            req.session.user = user
            req.session.password = CONFIG.DEV_PASSWORD
            req.user = user
            next()
          else
            req.session.redir = req.url
            res.redirect '/login'
      else
        req.session.redir = req.url
        res.redirect '/login'
    else
      req.user = req.session.user
      next()

  console.log 'Listening on port 3001'
  gameServer.init app.listen(3001), sessionStore, cookieParser
