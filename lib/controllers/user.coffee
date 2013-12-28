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
        Users.updateStoryPoints username, password, user, (err, user) ->
          if err?
            res.send 500, err
          else
            req.session.user = user
            redir = if req.session.redir? then req.session.redir else '/'
            delete req.session.redir
            res.redirect redir

  app.get '/user/logout', (req, res) ->
    req.session.user = null
    res.redirect '/'

  console.log 'Initialized user controller.'
