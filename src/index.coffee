# run npm install programmly
npmInstall        = require 'npm-command/lib/install'
changeCase        = require 'change-case'
isObject          = require 'util-ex/lib/is/type/object'
isArray           = require 'util-ex/lib/is/type/array'
Resource          = require 'isdk-resource'
Task              = require 'task-registry'
Logger            = require 'terminal-logger'
setPrototypeOf    = require 'inherits-ex/lib/setPrototypeOf'
#register the tasks execution to the task-registry factory.
require 'task-registry-isdk-tasks'

register          = Task.register
aliases           = Task.aliases
defineProperties  = Task.defineProperties
tasks             = Task 'Tasks'

path = Resource::fs.path

module.exports    = class ISDKTask
  register ISDKTask
  aliases ISDKTask, 'isdk'

  defineProperties @,
    cwd: # current working directory.
      type: 'String'
      value: '.'
    src: # it should be a string or array of string.
      type: ['String', 'Array']
    dest:
      type: 'String'
      value: './public'
    autoInstall:
      type: 'Boolean'

  constructor: -> return super

  initMissedTasks = (aTasks)->
    vPkgNames = aTasks.map (i)->
      result = i.name.split('/').join('-')
      result = changeCase.paramCase result
      if result.indexOf('task-registry') is -1
        result = 'task-registry-'+result
      result

    npmInstall vPkgNames, save:true, (err, data)->
      return console.error err if err
      aTasks.forEach (t, i)->
        try
          require vPkgNames[i]
          Task i.name, i.options
  initTasks: (aInitConfig, needAutoInstall)->
    vMissedTasks = []
    if isObject aInitConfig
      for name, opts of aInitConfig
        task = Task(name, opts)
        vMissedTasks.push name:name, options:opts unless task
      if needAutoInstall and vMissedTasks.length
        initMissedTasks vMissedTasks
    return
  initLogger: (aOptions)->
    @logger = tasks.logger = new Logger aOptions.logger
    return
  processSync: (aFile)-> #process a files in a folder
    vContents = aFile.contents
    if isArray vContents
      result = file:aFile
      result.result = for file in vContents
        continue unless file.filter file
        file.loadSync(read:true) unless file.loaded()
        task = @processSync(file)
        if !aFile.force and task.error
          result.error = true
          break
        task
    else if aFile and aFile.tasks
      result = file:aFile
      result.result = tasks.executeSync aFile
      result.error = tasks.lastError if tasks.lastError
    else
      @logger.status('ERROR', aFile, 'no any tasks to execute.')
      result =
        file: aFile
        error: 'no any tasks to execute'
    result
  _executeSync: (aOptions)->
    cwd = aOptions.cwd
    folder = Resource cwd, aOptions
    vNeedAutoInstall = aOptions.autoInstall
    delete aOptions.autoInstall
    try
      folder.loadSync read:true#, recursive:true
    catch err
      if aOptions.raiseError
        throw err
      else
        Logger('isdk').status 'error', folder.path, err.message
        return

    # check whether the cwd is changed via configuration!
    # TODO: it should be in resource-file?
    newCwd = path.resolve cwd, folder.cwd
    cwd = path.resolve cwd
    if newCwd != cwd
      vFolder = Resource newCwd
      try
        vFolder.loadSync read:true
      catch err
        if aOptions.raiseError
          throw err
        else
          Logger('isdk').status 'error', vFolder.path, err.message
          return
      setPrototypeOf vFolder, folder
      folder = vFolder
    delete aOptions.cwd
    delete aOptions.src
    delete aOptions.dest
    folder.assign(aOptions)

    @folder = folder
    @initLogger folder
    @initTasks folder['initConfig'], vNeedAutoInstall # the initialization configuration of tasks.
    @processSync folder
