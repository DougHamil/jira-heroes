http = require 'http'

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
  return encodeURIComponent('assignee="'+username+'" AND Status WAS NOT IN ("Closed", "Resolved") BEFORE "'+time+'" AND Status IN ("Closed", "Resolved") AND type = Bug')

bugsCreatedQuery = (username, time) ->
  return encodeURIComponent('reporter="'+username+'" AND type = Bug AND created > "'+time+'"')

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

    getBugsCreatedSince: (time, ignoreIssueKeys, username, password, cb) ->
      # Get closed bugs
      @search 'jql='+bugsCreatedQuery(username, time), username, password, (err, json) ->
        if err?
          cb err, json
        else
          keys = []
          json.issues = json.issues.filter (i) -> i.key not in ignoreIssueKeys
          count = json.issues.length
          for issue in json.issues
            keys.push issue.key
          cb null, count, keys

    getBugsClosedSince: (time, ignoreIssueKeys, username, password, cb) ->
      # Get closed bugs
      @search 'jql='+bugsClosedQuery(username, time), username, password, (err, json) ->
        if err?
          cb err, json
        else
          keys = []
          json.issues = json.issues.filter (i) -> i.key not in ignoreIssueKeys
          count = json.issues.length
          for issue in json.issues
            keys.push issue.key
          cb null, count, keys

    getTotalStoryPointsSince: (time, ignoreIssueKeys, username, password, cb) ->
      @search 'fields='+encodeURIComponent(config.jiraStoryPointsField)+'&jql='+closedIssuesQuery(username, time), username, password, (err, json) ->
        if err?
          cb err, json
        else
          keys = []
          points = 0
          json.issues = json.issues.filter (i) -> i.key not in ignoreIssueKeys
          for issue in json.issues
            if issue.fields?
              points += issue.fields[config.jiraStoryPointsField] ? 0
            keys.push(issue.key)
          cb null, points, keys

    getUser: (username, password, cb) ->
      opts = buildRequest(username, password)
      opts.path = '/rest/api/2/user?username='+username
      http.request(opts,tryParseResponse(cb)).end()

    getDateTime: ->
      date = new Date()
      year = date.getFullYear()
      month = date.getMonth() + 1
      month = if month < 10 then "0"+month else month
      day = date.getDate()
      day = if day < 10 then "0"+day else day
      hour = date.getHours()
      hour = if hour < 10 then "0"+hour else hour
      minute = date.getMinutes()
      minute = if minute < 10 then "0"+minute else minute
      return year+"/"+month+"/"+day+" "+hour+":"+minute
