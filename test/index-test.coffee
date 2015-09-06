chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

setImmediate    = setImmediate || process.nextTick

Task            = require 'task-registry'
register        = Task.register
aliases         = Task.aliases

require '../src'

class RootTask
  register RootTask
  aliases RootTask, 'Root', 'root'

  constructor: -> return super

class EchoTask
  register EchoTask, RootTask
  aliases EchoTask, 'Echo', 'echo'

  _executeSync: sinon.spy (aOptions)->aOptions.one+1

class SimpleTask
  register SimpleTask, RootTask
  aliases SimpleTask, 'Simple', 'single'

  constructor: -> return super

  Task.defineProperties SimpleTask,
    one:
      type: 'Number'
      value: 1 # the default value of the property.

  # (required)the task execution synchronously.
  # the argument aOptions object is optional.
  _executeSync: sinon.spy (aOptions)->aOptions.one+1
  # (optional)the task execution asynchronously.
  # the default is used `executeSync` to execute asynchronously.
  #execute: (aOptions, done)->

class AbcTask
  register AbcTask, SimpleTask

class A2Task
  SimpleTask.register A2Task
  _executeSync: (aOptions)-> 'a2:' + super aOptions

describe 'isdk task', ->
  task = Task 'isdk'
  beforeEach ->SimpleTask::_executeSync.reset()

  describe 'executeSync', ->
    it 'should run', ->
      task.executeSync cwd: __dirname
