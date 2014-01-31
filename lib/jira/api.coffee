http = require 'http'
moment = require 'moment'

tryParseResponse = (cb) ->
  return (res) ->
    data = ''
    res.on 'data', (chunk) ->
      data += chunk
    res.on 'end', () ->
      try
        cb null, JSON.parse(data)
      catch err
        cb err, data

authHeader = (username, password) ->
  return "Basic "+new Buffer(username + ":" + password).toString('base64')

closedIssuesQuery = (username, time) ->
  return encodeURIComponent('assignee="'+username+'" AND Status WAS NOT IN ("Closed", "Resolved") BEFORE "'+time+'" AND Status IN ("Closed", "Resolved")')

bugsClosedQuery = (username, time) ->
  return encodeURIComponent('assignee="'+username+'" AND Status WAS NOT IN ("Closed", "Resolved") BEFORE "'+time+'" AND Status IN ("Closed", "Resolved") AND type in (Bug, "Sub-Bug")')

bugsCreatedQuery = (username, time) ->
  return encodeURIComponent('reporter="'+username+'" AND type IN (Bug, "Sub-Bug") AND created > "'+time+'"')

module.exports = (config) ->
  buildRequest = (username, password)->
    opts =
      host: config.jiraHost
      port: config.jiraPort
    if username? and password?
      opts.headers =
        'Authorization': authHeader(username, password)
    return opts

  module =
    getIssueHistoryForUserSince: (time, user, username, password, cb) ->
      path = "/rest/api/2/search?fields=comment,*all&maxResults=100&expand=changelog&jql="+encodeURIComponent("(assignee = "+user+" OR assignee was "+user+" ) AND Updated >= #{time}")
      opts = buildRequest(username, password)
      opts.path = path
      http.request(opts, tryParseResponse(cb)).end()

    search: (query, username, password, cb) ->
      opts = buildRequest(username, password)
      opts.path = '/rest/api/2/search?'+query
      http.request(opts, tryParseResponse(cb)).end()

    getBugsCreatedSince: (time, username, password, cb) ->
      # Get closed bugs
      @search 'jql='+bugsCreatedQuery(username, time), username, password, (err, json) ->
        if err?
          cb err, json
        else
          count = json.issues.length
          cb null, count

    getBugsClosedSince: (time, username, password, cb) ->
      # Get closed bugs
      @search 'jql='+bugsClosedQuery(username, time), username, password, (err, json) ->
        if err?
          cb err, json
        else
          count = json.issues.length
          cb null, count

    getTotalStoryPointsSince: (time, username, password, cb) ->
      @search 'maxResults=200&fields='+encodeURIComponent(config.jiraStoryPointsField)+'&jql='+closedIssuesQuery(username, time), username, password, (err, json) ->
        if err?
          cb err, json
        else
          points = 0
          for issue in json.issues
            if issue.fields?
              points += issue.fields[config.jiraStoryPointsField] ? 0
          cb null, points

    getUser: (username, password, cb) ->
      opts = buildRequest(username, password)
      opts.path = '/rest/api/2/user?username='+username
      http.request(opts,tryParseResponse(cb)).end()

    getDateTime: (momentDate)->
      momentDate = moment() if not momentDate?
      return momentDate.format("YYYY/MM/DD hh:mm")
