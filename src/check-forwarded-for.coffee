_ = require 'lodash'
http = require 'http'

class CheckForwardedFor
  constructor: (options={}) ->
    {@uuidAliasResolver} = options

  _doCallback: (request, code, callback) =>
    response =
      metadata:
        responseId: request.metadata.responseId
        code: code
        status: http.STATUS_CODES[code]
    callback null, response

  do: (request, callback) =>
    {fromUuid} = request.metadata
    {uuid,token} = request.metadata.auth
    fromUuid ?= uuid
    return @_doCallback request, 403, callback unless uuid? and token?

    try message = JSON.parse request.rawData

    @uuidAliasResolver.resolve fromUuid, (error, fromUuid) =>
      if _.contains message?.forwardedFor, fromUuid
        return @_doCallback request, 508, callback

      @_doCallback request, 204, callback

module.exports = CheckForwardedFor
