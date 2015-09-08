chai            = require 'chai'
sinon           = require 'sinon'
sinonChai       = require 'sinon-chai'
should          = chai.should()
expect          = chai.expect
assert          = chai.assert
chai.use(sinonChai)

setImmediate    = setImmediate || process.nextTick

Resource        = require 'isdk-resource'
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

  _executeSync: sinon.spy (aOptions)->
    aOptions

findFile = (aName, aResource)->
  i = aResource.indexOfSync(aName)
  result = aResource.contents[i] if i isnt -1
  result

describe 'isdk task', ->
  task = Task 'isdk'
  beforeEach ->EchoTask::_executeSync.reset()

  describe 'executeSync', ->
    it 'should run correctly', ->
      result = task.executeSync cwd: __dirname + '/fixture'
      expect(EchoTask::_executeSync).to.be.calledOnce
      file = findFile 'test.md', task.root
      expect(EchoTask::_executeSync).to.be.calledWith file
      expect(result).to.have.length 1
      expect(result[0]).to.have.property 'file', file
      expect(result[0].result).to.have.length.at.least 1
      expect(result[0].result[0]).to.be.equal file

  describe 'execute', ->
    it 'should run correctly', (done)->
      task.execute cwd: __dirname + '/fixture', (err, result)->
        unless err
          expect(EchoTask::_executeSync).to.be.calledOnce
          file = findFile 'test.md', task.root
          expect(EchoTask::_executeSync).to.be.calledWith file
          expect(result).to.have.length 1
          expect(result[0]).to.have.property 'file', file
          expect(result[0].result).to.have.length.at.least 1
          expect(result[0].result[0]).to.be.equal file
        done(err)
