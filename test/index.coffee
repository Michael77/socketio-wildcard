'use strict'

{assert}   = require 'chai'
io         = require('socket.io')()
Client     = require('socket.io-client')
middleware = require "#{__dirname}/../"

describe 'socket.io wildcard middleware', ->
  nsp = undefined

  before ->
    nsp = io.of '/foo'
    io.use middleware()
    nsp.use middleware()
    io.listen 8000

  it 'should work', (done) ->
    client = Client('http://localhost:8000')
    client.on 'connect', ->
      client.emit 'foo', {bar: 'baz'}

    io.on 'connection', (socket) ->
      called = 0

      fn = ->
        called += 1
        done() if called is 2

      socket.on 'foo', (data) ->
        assert.deepEqual data, {bar: 'baz'}
        fn()

      socket.on '*', (packet) ->
        assert.deepPropertyVal packet, 'data[0]', 'foo'
        assert.deepPropertyVal packet, 'data[1].bar', 'baz'
        fn()

  it 'should work within namespace', (done) ->
    client = Client('http://localhost:8000/foo')
    client.on 'connect', ->
      client.emit 'foo', {bar: 'baz'}

    nsp.on 'connection', (socket) ->
      called = 0

      fn = ->
        called += 1
        done() if called is 2

      socket.on 'foo', (data) ->
        assert.deepEqual data, {bar: 'baz'}
        fn()

      socket.on '*', (packet) ->
        assert.deepPropertyVal packet, 'data[0]', 'foo'
        assert.deepPropertyVal packet, 'data[1].bar', 'baz'
        fn()
