Datastore = require 'meshblu-core-datastore'
CheckForwardedFor = require '..'

describe 'CheckForwardedFor', ->
  beforeEach ->
    @uuidAliasResolver = resolve: (uuid, callback) => callback null, uuid
    @sut = new CheckForwardedFor
      uuidAliasResolver: @uuidAliasResolver

  describe '->do', ->
    context 'when a loopback is detected', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'used-as-biofuel'
            auth:
              uuid: 'thank-you-for-considering'
              token: 'the-environment'
          rawData: '{"forwardedFor":["thank-you-for-considering"]}'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 508', ->
        expectedResponse =
          metadata:
            responseId: 'used-as-biofuel'
            code: 508
            status: 'Loop Detected'

        expect(@response).to.deep.equal expectedResponse

    context 'when a loopback is not detected', ->
      beforeEach (done) ->
        request =
          metadata:
            responseId: 'used-as-biofuel'
            auth:
              uuid: 'thank-you-for-considering'
              token: 'the-environment'

        @sut.do request, (error, @response) => done error

      it 'should respond with a 204', ->
        expectedResponse =
          metadata:
            responseId: 'used-as-biofuel'
            code: 204
            status: 'No Content'

        expect(@response).to.deep.equal expectedResponse
