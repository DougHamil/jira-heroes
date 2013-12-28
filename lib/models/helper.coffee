# Example usage:
#   deepPopulate(blogPost, "comments comments._creator comments._creator.blogposts", {sort:{title:-1}}, callback);
# Note that the options get passed at *every* level!
# Also note that you must populate the shallower documents before the deeper ones.
exports.deepPopulate = (doc, pathListString, options, callback) ->
  doNext = ->
    if listOfPathsToPopulate.length is 0
      # Now all the things underneath the original doc should be populated.  Thanks mongoose!
      callback null, doc
    else
      nextPath = listOfPathsToPopulate.shift()
      pathBits = nextPath.split(".")
      listOfDocsToPopulate = resolveDocumentzAtPath(doc, pathBits.slice(0, -1))
      if listOfDocsToPopulate.length > 0
        if not listOfDocsToPopulate[0]?
          doNext()
          return
        lastPathBit = pathBits[pathBits.length - 1]
        # There is an assumption here, that desendent documents which share the same path will all have the same model!
        # If not, we must make a separate populate request for each doc, which could be slow.
        model = listOfDocsToPopulate[0].constructor
        pathRequest = [
          path: lastPathBit
          options: options
        ]
        console.log "Populating field '" + lastPathBit + "' of " + listOfDocsToPopulate.length + " " + model.modelName + "(s)"
        model.populate listOfDocsToPopulate, pathRequest, (err, results) ->
          return callback(err)  if err
          #console.log("model.populate yielded results:",results);
          doNext()

      else
        # There are no docs to populate at this level.
        doNext()
  listOfPathsToPopulate = pathListString.split(" ")
  doNext()

resolveDocumentzAtPath = (doc, pathBits) ->
  return [doc]  if pathBits.length is 0
  #console.log("Asked to resolve "+pathBits.join(".")+" of a "+doc.constructor.modelName);
  resolvedSoFar = []
  firstPathBit = pathBits[0]
  resolvedField = doc[firstPathBit]
  unless resolvedField is `undefined` or resolvedField is null
    # There is no document at this location at present
    if Array.isArray(resolvedField)
      resolvedSoFar = resolvedSoFar.concat(resolvedField)
    else
      resolvedSoFar.push resolvedField
  #console.log("Resolving the first field yielded: ",resolvedSoFar);
  remainingPathBits = pathBits.slice(1)
  if remainingPathBits.length is 0
    resolvedSoFar # A redundant check given the check at the top, but more efficient.
  else
    furtherResolved = []
    resolvedSoFar.forEach (subDoc) ->
      deeperResults = resolveDocumentzAtPath(subDoc, remainingPathBits)
      furtherResolved = furtherResolved.concat(deeperResults)

    furtherResolved
