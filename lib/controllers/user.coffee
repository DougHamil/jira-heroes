module.exports = (app, Users) ->
  app.post '/user/login', (req, res) ->
    username = req.body.username
    password = req.body.password
    Users.login username, password, (err, user) ->
      if err?
        req.session.loginFailed = true
        res.redirect '/login'
      else
        # Update and save story points since last login
        ###
        Users.updateStoryPoints username, password, user, (err, user) ->
          if err?
            res.send 500, err
          else
            req.session.user = user
            redir = if req.session.redir? then req.session.redir else '/'
            delete req.session.redir
            res.redirect redir
        ###
        req.session.user = user
        redir = if req.session.redir? then req.session.redir else '/'
        delete req.session.redir
        res.redirect redir

  app.post '/user/find', (req, res) ->
    userIds = req.body.users
    if userIds?
      err = null
      try
        userIds = JSON.parse(req.body.users)
      catch ex
        err = ex
      if err? or not userIds instanceof Array
        res.send 400, "Expected 'users'"
      else
        Users.get userIds, (err, users) ->
          if err?
            res.send 500, err
          else
            users = users.map (u) -> u.getPublicData()
            res.json users
    else
      res.send 400, "Expected 'users'"


  app.get '/secure/user', (req, res) ->
    Users.fromSession req.session.user, (err, user) ->
      if err?
        res.send 500, err
      else
        res.json user

  app.get '/user/logout', (req, res) ->
    req.session.user = null
    res.redirect '/'

  console.log 'Initialized user controller.'
