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
      expect(EchoTask::_executeSync).to.be.callCount 4
      testFile = task.folder.findSync 'test.md'
      f1File = task.folder.findSync 'f1.md'
      zFolder = task.folder.findSync 'zfolder'
      #expect(EchoTask::_executeSync).to.be.calledWith testFile

      expect(result).to.be.deep.equal file:task.folder, result:[
        file: testFile, result: [testFile, 21]
      , file: zFolder, result: [
          { file: f1File, result: [ f1File, 21 ] }
        ]
      ]

  describe 'execute', ->
    it 'should run correctly', (done)->
      task.execute cwd: __dirname + '/fixture', (err, result)->
        unless err
          expect(EchoTask::_executeSync).to.be.callCount 4
          testFile = task.folder.findSync 'test.md'
          f1File = task.folder.findSync 'f1.md'
          zFolder = task.folder.findSync 'zfolder'
          #expect(EchoTask::_executeSync).to.be.calledWith file
          expect(result).to.be.deep.equal file:task.folder, result:[
            file: testFile, result: [testFile, 21]
          , file: zFolder, result: [
              { file: f1File, result: [ f1File, 21 ] }
            ]
          ]
        done(err)
